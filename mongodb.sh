#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

if [ $USER_ID -ne 0 ] ; then
    echo "you are not root user. Please run the script as root user"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo -e " $2 ....$R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ....$G SUCCESS $N" | tee -a $LOG_FILE
    fi 
}

cp mongo.repo /etc/yum.repos.d/mongo.repo >>$LOG_FILE
VALIDATE $? "copying the mongo.repo file"

dnf install mongodb-org -y >>$LOG_FILE
VALIDATE $? "installing MongoDB"

systemctl enable mongod >>$LOG_FILE
VALIDATE $? "enabling MongoDB"

systemctl start mongod >>$LOG_FILE
VALIDATE $? "starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0 /g' /etc/mongod.conf >>$LOG_FILE
VALIDATE $? "updating the bind_ip in mongod.conf"

systemctl restart mongod >>$LOG_FILE
VALIDATE $? "restarting MongoDB"
