#!/bin/bash

export subnet=$(ip route | grep -v default | grep enp0s8 | awk '{print $1}')
export ip=$(ip route | grep -v default | grep enp0s8 | awk '{print $9}')

echo "$ip k8smaster" >> /etc/hosts
echo "$ip k8smaster" >  /vagrant/k8smaster

rm /vagrant/calico.yaml
wget -q https://docs.projectcalico.org/manifests/calico.yaml -O /vagrant/calico.yaml
sed -i 's/            # - name: CALICO_IPV4POOL_CIDR/            - name: CALICO_IPV4POOL_CIDR/' /vagrant/calico.yaml
sed -i 's,            #   value: "192.168.0.0\/16",              value: '"$subnet"',' /vagrant/calico.yaml

sed -i "/podSubnet/c\  podSubnet: $subnet" /vagrant/kubeadm-config.yaml
kubeadm init --config=/vagrant/kubeadm-config.yaml --upload-certs | tee /vagrant/kubeadm-init.out

mkdir -p /home/vagrant/.kube
cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc

su - vagrant -c "kubectl apply -f /vagrant/calico.yaml"

kubeadm token create --print-join-command > /vagrant/joincluster.sh
 
