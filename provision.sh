#!/bin/bash

swapoff -a
#sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

apt-get update
apt-get upgrade -y
apt-get install -y apt-transport-https nano vim bash-completion

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"


apt-get install -y docker.io 
apt-get install -y kubeadm=1.19.1-00 kubelet=1.19.1-00 kubectl=1.19.1-00
apt-mark hold kubelet kubeadm kubectl

systemctl enable docker.service
systemctl enable kubelet.service

usermod -aG docker vagrant

