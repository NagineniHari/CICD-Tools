#!/bin/bash

#resize disk from 20GB to 50GB
growpart /dev/xvda 4

lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -L +10G /dev/mapper/RootVG-rootVol
lvextend -l +100%FREE /dev/mapper/RootVG-homeVol

xfs_growfs /
xfs_growfs /var
xfs_growfs /home

# This is mandatory, nodejs installtion will break SSH if we dont update these packages
dnf update -y openssl\* openssh\* -y
yum install java-21-openjdk -y

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y

# docker
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
