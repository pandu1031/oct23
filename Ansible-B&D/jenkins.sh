#!/bin/bash
#installing git
sudo yum install git -y

#installing maven
   sudo yum install maven -y
   mvn --version
   sudo yum install java-11-amazon-corretto -y
    java --version
   sudo yum remove java-17-amazon-corretto-headless -y

#installing jenkins

##!/bin/bash
sudo yum update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
java --version
if [ $? == 0 ];
then
       echo "We have Java installed in the machine"
else
        echo "Java not installed. Installing"
        sudo amazon-linux-extras install java-openjdk11 -y
fi

sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo systemctl daemon-reload
sudo systemctl restart jenkins
