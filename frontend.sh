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

dnf module disable nginx -y &>>$SCRIPT_DIR
VALIDATE $? "disabling the default version of the nginx"

dnf module enable nginx:1.26 -y &>>$SCRIPT_DIR
VALIDATE $? "enable the nginx "

dnf install nginx -y &>>$SCRIPT_DIR
VALIDATE $? "install the nginx"

systemctl enable nginx &>>$SCRIPT_DIR
systemctl start nginx
VALIDATE  $? "start and enable the nginx"

rm -rf /usr/share/nginx/html/* &>>$SCRIPT_DIR
VALIDATE $? "removing the default version"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>>$SCRIPT_DIR
VALIDATE $? "download the code"

cd /usr/share/nginx/html &>>$SCRIPT_DIR
VALIDATE $? "moving to the html"

unzip /tmp/frontend.zip &>>$SCRIPT_DIR
VALIDATE $? "unzip the code"

cp $SCRIPT_DIR/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$SCRIPT_DIR
VALIDATE $? "configure the robosho.conf"

nginx -t &>>$SCRIPT_DIR
VALIDATE $? "checking the syntax"

systemctl restart nginx &>>$SCRIPT_DIR
VALIDATE $?"restarting the nginx"

