#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.daws880s.online

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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "installing the maven"

id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
    echo " id robosop user not created creating now "
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating the user"
else
    echo "roboshop user created skipping now"
fi

mkdir -p  /app  &>>$LOG_FILE
VALIDATE $? "creating the app directoru user"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "copying the code to temp location"

cd /app &>>$LOG_FILE
VALIDATE $? "moving to the app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "removing the app directory unwamted files"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unziping the code"

cd /app &>>$LOG_FILE
VALIDATE $? "moving to the app directory"

mvn clean package &>>$LOG_FILE
VALIDATE $? "installing the packages"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "renaming the file name"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "copying the service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon-reload"
systemctl enable shipping &>>$LOG_FILE
systemctl start shipping &>>$LOG_FILE
VALIDATE $? "start and enable the shipping"

dnf install mysql -y 
VALIDATE $? "installing the mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? "loading the db schema"