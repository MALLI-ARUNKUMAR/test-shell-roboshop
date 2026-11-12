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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disbale the default version redis version"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabling the redis 7 version"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing the redis "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "enabling the remote connection"

systemctl enable redis 
systemctl start redis &>>$LOG_FILE
VALIDATE $? "enable and start the redis"
