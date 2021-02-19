#!/bin/bash

export subnet=$1
export ip=$(ip route | grep -v default | grep enp0s8 | awk '{print $9}')

# Set iptables bridging
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo echo '1' > /proc/sys/net/ipv4/ip_forward
sudo sysctl --system

kubeadm reset --force
kubeadm init --pod-network-cidr=$subnet --apiserver-advertise-address=$ip --upload-certs | tee /vagrant/kubeadm-init.out


mkdir -p /home/vagrant/.kube
cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl


wget -q https://docs.projectcalico.org/manifests/calico.yaml -O /vagrant/calico.yaml
sed -i 's/            # - name: CALICO_IPV4POOL_CIDR/            - name: CALICO_IPV4POOL_CIDR/' /vagrant/calico.yaml
sed -i 's,            #   value: "192.168.0.0\/16",              value: '"$subnet"',' /vagrant/calico.yaml
su - vagrant -c "kubectl apply -f /vagrant/calico.yaml"
rm /vagrant/calico.yaml

# Create script to join cluster with 24h valid token
kubeadm token create --print-join-command > /vagrant/joincluster.sh
chmod +x /vagrant/joincluster.sh
