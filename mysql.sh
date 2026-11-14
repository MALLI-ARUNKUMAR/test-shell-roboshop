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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing the mysql-server"

systemctl enable mysqld
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "start and enable the mysqld"
mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "assigning the password"


