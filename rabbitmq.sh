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

cp rabbitmq /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "creating the repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing the rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server
VALIDATE $? "start and enable the rabbitmq-server"

read -s -p "Enter MySQL root password: " MYSQL_PASSWORD 
rabbitmqctl add_user roboshop "$MYSQL_PASSWORD" &>>$LOG_FILE
VALIDATE $? "creating the user and assign the password"

# Clear password variable
unset MYSQL_PASSWORD

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "set permission"