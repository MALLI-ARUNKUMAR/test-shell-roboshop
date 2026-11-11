#!/bin/bash

USER_ID=$(id -u)

if [ $USER_ID -ne 0 ] ; then
    echo "you are not root user. Please run the script as root user"
    exit 1
fi