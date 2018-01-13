#!/bin/bash
# recon - basic recon of bugbounty target scope
# by bl4de | https://twitter.com/_bl4de

# params
TARGET=$1
SUBDOMAINS=$2

echo "[+] running recon.sh against $TARGET, please stand by..."
# enumerate subdomains
if [ -z $2 ]
then
    echo "[+] execute sublist3r $TARGET saving output to $TARGET_out file..."
    sublist3r -d $TARGET > $TARGET"_out"
    echo "[+] small sed-ing..."
    cat $TARGET"_out" | sed  -e 's/\[92//;1,24d' > $TARGET"_subdomains"
    SUBDOMAINS=$TARGET"_subdomains"
else
    echo "[+] using $2 as subdomains list"
    SUBDOMAINS=$2
fi

#  nmap 
echo "[+] scanning and directories/files discovery"
while read DOMAIN; do
    echo "[+] current target: $DOMAIN"
    nmap -sV -F $DOMAIN -oG $DOMAIN"_nmap" # 1> /dev/null
    
    while read line; do
        if [[ $line == *"80/open/tcp//http"* ]]
        then
            echo "[+] found webserver on $DOMAIN port 80/HTTP, running files/directories discovery..."
            wfuzz -f $DOMAIN"_wfuzz_80",raw --hc 404,301,302,401,000 -w dict.txt http://$DOMAIN/FUZZ # 1> /dev/null
        fi
        if [[ $line == *"443/open/tcp//http"* ]]
        then
            echo "[+] found webserver on $DOMAIN port 80/HTTP, running files/directories discovery..."
            wfuzz -f $DOMAIN"_wfuzz_443",raw --hc 404,301,302,401,000 -w dict.txt https://$DOMAIN/FUZZ # 1> /dev/null
        fi
        if [[ $line == *"8080/open/tcp//http"* ]]
        then
            echo "[+] found webserver on $DOMAIN port 80/HTTP, running files/directories discovery..."
            wfuzz -f $DOMAIN"_wfuzz_8080",raw --hc 404,301,302,401,000 -w dict.txt http://$DOMAIN:8080/FUZZ # 1> /dev/null
        fi
        if [[ $line == *"8008/open/tcp//http"* ]]
        then
            echo "[+] found webserver on $DOMAIN port 80/HTTP, running files/directories discovery..."
            wfuzz -f $DOMAIN"_wfuzz_8008",raw --hc 404,301,302,401,000 -w dict.txt http://$DOMAIN:8008/FUZZ # 1> /dev/null
        fi
    done < $DOMAIN"_nmap"
done < $TARGET"_subdomains"

echo "[+] all done!!!"
echo
exit