#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"

if [ $USER_ID -ne 0 ] ; then
    echo "you are not root user. Please run the script as root user "
    exit 1
fi
mkdir -p $LOGS_FOLDER

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo " $2 .... FAILURE "
        exit 1
    else
        echo " $2 ....SUCCESS "
    fi        
}

dnf install mysql-server -y
VALIDATE $? "installing the mysql-server"

systemctl enable mysqld
systemctl start mysqld  
VALIDATE $? "start and enable the mysqld"

# Set MySQL root password securely
read -s -p "Enter MySQL root password: " MYSQL_PASSWORD
echo

mysql_secure_installation --set-root-pass "$MYSQL_PASSWORD"
VALIDATE $? "assigning the password"

# Clear password variable
unset MYSQL_PASSWORD

echo "MySQL installation completed successfully!"
