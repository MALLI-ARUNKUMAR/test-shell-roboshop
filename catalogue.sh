#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws880s.online

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling the nodejs module"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling the nodejs module"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ] ; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating roboshop user"
else
    echo "roboshop user already exists, skipping"
fi    

mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading catalogue zip file"

cd /app &>>$LOG_FILE
VALIDATE $? "changing directory to app"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "Removing the exisiting code"

unzip -o /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzipping catalogue zip file"

cd /app 
VALIDATE $? "changing directory to app"

npm install &>>$LOG_FILE
VALIDATE $? "installing nodejs dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "creating the systemctl service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon-reload"

systemctl enable catalogue 
VALIDATE $? "enabling the catalogue"

systemctl start catalogue
VALIDATE $? "start the catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y
VALIDATE $? "installing the mongodb"

mongosh --host $MONGODB_HOST </app/db/master-data.js

Index=$(mongosh --host $MONGODB_HOST  --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [$Index -le 0] ; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "products is loading"
else
    echo -e "products already loaded....$Y skipping $N "
fi
systemctl restart catalogue
VALIDATE $? "restating the catalogue"        
