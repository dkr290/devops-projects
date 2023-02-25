sudo apt-get -y update
sudo apt-get -y install  ca-certificates  curl   gnupg  apt-transport-https   lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt -y install containerd.io

sudo touch /etc/modules-load.d/br_netfilter.conf

echo br_netfilter | sudo tee -a /etc/modules-load.d/br_netfilter.conf
echo overlay      | sudo tee -a /etc/modules-load.d/overlay.conf
echo net.ipv4.ip_forward=1  | sudo tee -a /etc/sysctl.conf
echo net.bridge.bridge-nf-call-iptables=1 |  sudo tee -a /etc/sysctl.conf
echo net.bridge.bridge-nf-call-ip6tables =1 |  sudo tee -a /etc/sysctl.conf

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml



sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


#### under 
###   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    ###  ...
######## SystemdCgroup = true