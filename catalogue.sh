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
        echo  " $2 .... FAILURE " | tee -a $LOG_FILE
        exit 1
    else
        echo  "$2 .... SUCCESS " | tee -a $LOG_FILE
    fi 
}

dnf module disable nodejs -y
VALIDATE $? "disabling the nodejs module"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling the nodejs module"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ] ; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating roboshop user"
else
    echo "roboshop user already exists, skipping"
fi    

mkdir -p /app 
VALIDATE $? "creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading catalogue zip file"

cd /app
VALIDATE $? "changing directory to app"

rm -rf/app/*
VALIDATE $? "Removing the exisiting code"

unzip -o /tmp/catalogue.zip
VALIDATE $? "unzipping catalogue zip file"

cd /app 
VALIDATE $? "changing directory to app"

npm install 
VALIDATE $? "installing nodejs dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "creating the systemctl service"

systemctl daemon-reload
VALIDATE $? "daemon-reload"

systemctl enable catalogue 
VALIDATE $? "enabling the catalogue"

systemctl start catalogue
VALIDATE $? "start the catalogue"


