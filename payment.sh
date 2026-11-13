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

dnf install python3.14 python3.14-pip -y &>>$LOG_FILE
VALIDATE $? "installing the python version"
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    echo " roboshop user not created creating now"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating the roboshop user"
else
    echo "roboshop user already created skipping now"
fi 

mkdir -p /app &>>$LOG_FILE
VALIDATE $? " creating the app directory"

curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip &>>$LOG_FILE
VALIDATE $? "movin application to temp directory"

cd /app &>>$LOG_FILE
VALIDATE $? "moving to the app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "removing the unwanted files"

cd /app &>>$LOG_FILE
VALIDATE $? "moving to the app directory"



python3.14 -m venv /app/.venv &>>$LOG_FILE
VALIDATE $? "Creating virtual environment"

/app/.venv/bin/pip install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "creating the services file "

systemctl daemon-reload 
systemctl enable payment
systemctl start payment &>>$LOG_FILE
VALIDATE $? "enable and start the payment"

 