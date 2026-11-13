#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"


if [ $USER_ID -ne 0 ]; then
    echo"user is not root user please run the script using the root user"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo "$2 ....FAILURE"
    else
        echo "$2....SUCCESS" 
    fi       

}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling the default version of the nginx"

dnf module enable nginx:1.26 -y &>>$LOG_FILE
VALIDATE $? "enable the nginx "

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "install the nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx
VALIDATE  $? "start and enable the nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "removing the default version"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>>$LOG_FILE
VALIDATE $? "download the code"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "moving to the html"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip the code"

cp $SCRIPT_DIR/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
VALIDATE $? "configure the robosho.conf"

nginx -t &>>$LOG_FILE
VALIDATE $? "checking the syntax"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $?"restarting the nginx"

