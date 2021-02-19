#!/bin/bash

swapoff -a
sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
service systemd-resolved restart


apt-get update
apt-get upgrade -y
apt-get install -y apt-transport-https nano vim bash-completion

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"

apt-get install -y docker.io 
#apt-get install -y kubeadm=1.19.1-00 kubelet=1.19.1-00 kubectl=1.19.1-00
apt-get install -y kubeadm=1.20.1-00 kubelet=1.20.1-00 kubectl=1.20.1-00
apt-mark hold kubelet kubeadm kubectl

# Set kubelet options for cgroup driver (systemd) and network settings for virtual box
ip=$(ip route | grep -v default | grep enp0s8 | awk '{print $9}')
kubeletExtraArgs="KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --node-ip=$ip"
sed -ie "/^ExecStart=/i Environment=\"$kubeletExtraArgs\"" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

cat <<EOF >/etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF


systemctl daemon-reload
systemctl enable docker.service
systemctl enable kubelet.service
systemctl restart docker.service
systemctl restart kubelet.service

usermod -aG docker vagrant
