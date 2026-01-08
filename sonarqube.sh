#!/bin/bash
set -e

############################
# Disk resize
############################
sudo growpart /dev/nvme0n1 4

sudo lvextend -L +10G /dev/mapper/RootVG-varVol
sudo lvextend -L +10G /dev/mapper/RootVG-rootVol
sudo lvextend -l +100%FREE /dev/mapper/RootVG-homeVol

sudo xfs_growfs /
sudo xfs_growfs /var
sudo xfs_growfs /home

############################
# Kernel requirements
############################
sudo sysctl -w vm.max_map_count=524288
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf

############################
# Docker installation
############################
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

############################
# Docker network
############################
docker network create sonarnet || true

############################
# PostgreSQL (SUPPORTED)
############################
docker run -d \
  --name sonarqube-db \
  --network sonarnet \
  -e POSTGRES_USER=sonar \
  -e POSTGRES_PASSWORD=sonar \
  -e POSTGRES_DB=sonarqube \
  -v sonardb:/var/lib/postgresql/data \
  postgres:13-alpine

############################
# SonarQube (LTS ONLY)
############################
docker run -d \
  --name sonarqube \
  --network sonarnet \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://sonarqube-db:5432/sonarqube \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:9.9-community
