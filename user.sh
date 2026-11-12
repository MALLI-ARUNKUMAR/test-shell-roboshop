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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling the nodejs current version"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling the nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install the nodejs"

id roboshop &>>$LOG_FILE

if [ $? -ne 0] ; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating the system user"
else
    echo  -e "user already is created ......$Y skippin $N"
fi 

mkdir -p  /app 
VALIDATE $? "creating the app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATE $? "copying the code to tempory location"

cd /app 
VALIDATE $? "moving to the app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "removing the fils from the app directory"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "unziping the code"

cd /app  &>>$LOG_FILE
VALIDATE $? "moving the app location"

npm install 
VALIDATE $? "installing the dependences"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATE $? "creating the systemctl services"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "system daemon-reload"

systemctl enable user 
systemctl start user &>>$LOG_FILE
VALIDATE $? "start and enable the user"



