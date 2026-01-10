#!/bin/bash

#resize disk from 20GB to 50GB
## growpart /dev/xvda 4
sudo growpart /dev/nvme0n1 4

sudo lvextend -L +10G /dev/mapper/RootVG-varVol
sudo lvextend -L +10G /dev/mapper/RootVG-rootVol
sudo lvextend -l +100%FREE /dev/mapper/RootVG-homeVol

sudo xfs_growfs /
sudo xfs_growfs /var
sudo xfs_growfs /home

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

## Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

## Trivy Installing
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.68.2

## Kubernetes installation
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.34.2/2025-11-13/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
##Install k9s
curl -sS https://webinstall.dev/k9s | bash
##Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh