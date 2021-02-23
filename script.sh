#!/bin/bash

cd /tmp
sudo amazon-linux-extras install java-openjdk11

echo "" >> /home/ec2-user/.ssh/authorized_keys

wget https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar

mkdir /home/ec2-user/minecraft
mv ./server.jar /home/ec2-user/minecraft/
echo "eula=true" > /home/ec2-user/minecraft/eula.txt

echo "[Unit]" >> /etc/systemd/system/minecraft.service
echo "Description=start and stop the minecraft-server " >> /etc/systemd/system/minecraft.service
echo "After=network.target" >> /etc/systemd/system/minecraft.service
echo "[Service]" >> /etc/systemd/system/minecraft.service
echo "WorkingDirectory=/home/ec2-user/minecraft" >> /etc/systemd/system/minecraft.service
echo "Type=Forking" >> /etc/systemd/system/minecraft.service
echo "User=root" >> /etc/systemd/system/minecraft.service
echo "Restart=on-failure" >> /etc/systemd/system/minecraft.service
echo "RestartSec=20 5" >> /etc/systemd/system/minecraft.service
echo "RemainAfterExit=yes" >> /etc/systemd/system/minecraft.service
echo "ExecStart=/usr/bin/screen -L -dm java -Xms1536M -Xmx1536M -jar server.jar nogui" >> /etc/systemd/system/minecraft.service
echo "[Install]" >> /etc/systemd/system/minecraft.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/minecraft.service

echo "*/10 * * * * tar -czvf /tmp/world.tar.gz /home/ec2-user/minecraft/world" >> /var/spool/cron/root
echo "*/15 * * * * aws s3api put-object --bucket ${bucket_name} --key world.tar.gz --body /tmp/world.tar.gz" >> /var/spool/cron/root

systemctl start minecraft
