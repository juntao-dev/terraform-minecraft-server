#!/bin/bash

cd /tmp
sudo amazon-linux-extras install java-openjdk11
su ec2-user
wget https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar
echo "eula=true" > eula.txt
nohup java -Xmx1024M -Xms1024M -jar server.jar nogui &
