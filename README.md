# ssh_ftp_brute_force
This script will allow you to perform a brute force attack on the ssh and ftp services.

---- Author: h3g0c1v ----
# SSH and FTP Brute Force
## Description:
This script will allow you to perform a brute force attack on the ssh and ftp services.

## How to use this tool:

./ssh_ftp_brute_force -s {SSH|FTP} [OPCIONES] -i SERVIDOR

## Examples:
- ./ssh_ftp_brute_force -s SSH -u pepe -w passwordsList.txt -i 11.11.11.11
- ./ssh_ftp_brute_force -s SSH -l usersList.txt -p 'P@Ssw0rd*.!' -i 11.11.11.11
- ./ssh_ftp_brute_force -s SSH -l usersList.txt -w passwordsList.txt -i 11.11.11.11
- ./ssh_ftp_brute_force -s FTP -u pepe -w passwordsList.txt -i 11.11.11.11
- ./ssh_ftp_brute_force -s FTP -l usersList.txt -p 'P@Ssw0rd*.!' -i 11.11.11.11
- ./ssh_ftp_brute_force -s FTP -l usersList.txt -w passwordsList.txt -i 11.11.11.11

I hope it helps you <3
