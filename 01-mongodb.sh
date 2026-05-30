#1/bin/bash

LOGS_FOLDER="/var/logs/roboshop" #folder created in var/log to store all the logs of roboshop installation
sudo mkdir -p $LOGS_FOLDER #-p will create the parent directory if it does not exist, and it will not throw an error if the directory already exists
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER #ec2-user is given permission to write
sudo chmod -R 755 $LOGS_FOLDER #ec2-user is given permission to read, write, and execute
LOGS_FILE="$LOGS_FOLDER/01-mongodb.log"  #log file created for mongodb installation logs

USERID=$(id -u) #it will give the user id of the current user
R=\e[31m"  #red color code
G=\e[32m" #green color code
Y=\e[33m"  # yellow color code
N=\e[0m"   #no color code
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S") #it will give the current date and time in the specified format

if [ $USERID -ne 0 ]; then #if the user id is not equal
    echo -e " $TIMESTAMP [ERROR] ${R}please run the script with root access${N}" | tee -a $LOGS_FILE #tee command is used to write the output to the log file and also display it on the console
    exit 1 #exit code 1 means there is an error
fi

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo -e " $TIMESTAMP [ERROR] $2 .... ${R} FAILURE ${N}" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e " $TIMESTAMP [INFO] $2 .... ${G} SUCCESS ${N}" | tee -a $LOGS_FILE
    fi

}
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo" #$? will give the exit code of the last command executed

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable --now mongod  &>> $LOGS_FILE
VALIDATE $? "Starting and Enabling MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing Remote Connections to MongoDB"

systemctl restart mongod  &>> $LOGS_FILE
VALIDATE $? "Restarting MongoDB"

