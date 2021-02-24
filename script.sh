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

echo "I01pbmVjcmFmdCBzZXJ2ZXIgcHJvcGVydGllcwojVGh1IEZlYiAyNSAwMDozOTo1MCBBRURUIDIwMjEKZW5hYmxlLWpteC1tb25pdG9yaW5nPWZhbHNlCnJjb24ucG9ydD0yNTU3NQpsZXZlbC1zZWVkPQpnYW1lbW9kZT1zdXJ2aXZhbAplbmFibGUtY29tbWFuZC1ibG9jaz1mYWxzZQplbmFibGUtcXVlcnk9ZmFsc2UKZ2VuZXJhdG9yLXNldHRpbmdzPQpsZXZlbC1uYW1lPXdvcmxkCm1vdGQ9QSBNaW5lY3JhZnQgU2VydmVyCnF1ZXJ5LnBvcnQ9MjU1NjUKcHZwPXRydWUKZ2VuZXJhdGUtc3RydWN0dXJlcz10cnVlCmRpZmZpY3VsdHk9aGFyZApuZXR3b3JrLWNvbXByZXNzaW9uLXRocmVzaG9sZD0yNTYKbWF4LXRpY2stdGltZT02MDAwMAp1c2UtbmF0aXZlLXRyYW5zcG9ydD10cnVlCm1heC1wbGF5ZXJzPTIwCm9ubGluZS1tb2RlPWZhbHNlCmVuYWJsZS1zdGF0dXM9dHJ1ZQphbGxvdy1mbGlnaHQ9dHJ1ZQpicm9hZGNhc3QtcmNvbi10by1vcHM9dHJ1ZQp2aWV3LWRpc3RhbmNlPTE0Cm1heC1idWlsZC1oZWlnaHQ9MjU2CnNlcnZlci1pcD0KYWxsb3ctbmV0aGVyPXRydWUKc2VydmVyLXBvcnQ9MjU1NjUKZW5hYmxlLXJjb249ZmFsc2UKc3luYy1jaHVuay13cml0ZXM9dHJ1ZQpvcC1wZXJtaXNzaW9uLWxldmVsPTQKcHJldmVudC1wcm94eS1jb25uZWN0aW9ucz1mYWxzZQpyZXNvdXJjZS1wYWNrPQplbnRpdHktYnJvYWRjYXN0LXJhbmdlLXBlcmNlbnRhZ2U9MTAwCnJjb24ucGFzc3dvcmQ9CnBsYXllci1pZGxlLXRpbWVvdXQ9MApmb3JjZS1nYW1lbW9kZT1mYWxzZQpyYXRlLWxpbWl0PTAKaGFyZGNvcmU9ZmFsc2UKd2hpdGUtbGlzdD1mYWxzZQpicm9hZGNhc3QtY29uc29sZS10by1vcHM9dHJ1ZQpzcGF3bi1ucGNzPXRydWUKc3Bhd24tYW5pbWFscz10cnVlCnNub29wZXItZW5hYmxlZD10cnVlCmZ1bmN0aW9uLXBlcm1pc3Npb24tbGV2ZWw9MgpsZXZlbC10eXBlPWRlZmF1bHQKdGV4dC1maWx0ZXJpbmctY29uZmlnPQpzcGF3bi1tb25zdGVycz10cnVlCmVuZm9yY2Utd2hpdGVsaXN0PWZhbHNlCnJlc291cmNlLXBhY2stc2hhMT0Kc3Bhd24tcHJvdGVjdGlvbj0xNgptYXgtd29ybGQtc2l6ZT0yOTk5OTk4NAo=" | base64 -d >> /home/ec2-user/minecraft/server.properties

systemctl start minecraft
