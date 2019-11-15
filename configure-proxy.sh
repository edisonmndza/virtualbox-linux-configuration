#!/usr/bin/env bash
# Gather username and password required
USER=${1?Error: no username}
PASS=${2?Error: no password attach}

#add proxy lines to environment variables if they don't already exist 
grep -q 'http_proxy=.*' /etc/environment && sed -i -E "s/http_proxy=.*/http_proxy=\"http:\/\/$USER:$PASS@stcweb.statcan.ca\/\"/g" /etc/environment || echo "http_proxy=\"http://$USER:$PASS@stcweb.statcan.ca/\"" >> /etc/environment
grep -q 'https_proxy=.*' /etc/environment && sed -i -E "s/https_proxy=.*/https_proxy=\"http:\/\/$USER:$PASS@stcweb.statcan.ca\/\"/g" /etc/environment || echo "https_proxy=\"http://$USER:$PASS@stcweb.statcan.ca/\"" >> /etc/environment
grep -q 'ftp_proxy=.*' /etc/environment && sed -i -E "s/ftp_proxy=.*/ftp_proxy=\"http:\/\/$USER:$PASS@stcweb.statcan.ca\/\"/g" /etc/environment || echo "ftp_proxy=\"http://$USER:$PASS@stcweb.statcan.ca/\"" >> /etc/environment
grep -q 'no_proxy=.*' /etc/environment && sed -i -E "s/no_proxy=.*/no_proxy=\"127.0.0.1,::1,.cloud.statcan.ca,.k8s.cloud.statcan.ca,172.16.0.0\/12\"/g" /etc/environment || echo "no_proxy=\"127.0.0.1,localhost,::1,.cloud.statcan.ca,.k8s.cloud.statcan.ca,172.16.0.0/12/\"" >> /etc/environment

#reload environment variables for the current terminal session
. /etc/environment

#run apt update and upgrade
apt-get update 
apt-get upgrade -y

#make sure squid is not installed
apt-get purge squid -y
apt autoremove -y

#install squid
apt-get install squid -y

#systemctl start and enable squid
systemctl start squid.service && systemctl enable squid.service 

# #add following lines to squid.conf 
grep -q "http_access allow all" /etc/squid/squid.conf || echo "http_access allow all" >> /etc/squid/squid.conf
grep -q "cache_peer stc*" /etc/squid/squid.conf || echo "cache_peer stcweb.statcan.ca parent 80 0 no-query default login=USERNAME:PASSWORD" >> /etc/squid/squid.conf
grep -q "^never_direct allow all" /etc/squid/squid.conf || echo "never_direct allow all" >> /etc/squid/squid.conf
