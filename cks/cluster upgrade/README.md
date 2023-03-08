
1. kubectl drain
2. Do upgrade
3. kubectl uncordon


*POdDisruptionBudget

## control plane in single master
```
 kubectl drain <node-to-drain> --ignore-daemonsets
 apt-cache show kubeadm | grep kubeadm


 apt-mark unhold kubeadm 
 apt-get update && apt-get install -y kubeadm=1.26.2-00 
 apt-mark hold kubeadm


 kubeadm version

 kubeadm upgrade plan


 kubeadm upgrade apply v1.26.2


 kubelet --version

 kubectl version

apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=1.26.2-00 kubectl=1.26.2-00 && \
apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl uncordon <node-to-uncordon>


```

## upgrade the node
```
#on the master
k drain <node-to-drain> --ignore-daemonsets

#on the node
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=1.26.2-00 && \
apt-mark hold kubeadm

kubeadm version
kubeadm upgrade node

apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=1.26.2-00 kubectl=1.26.2-00 && \
apt-mark hold kubelet kubectl

systemctl daemon-reload
systemctl restart kubelet

# on master 
kubectl uncordon <node-to-uncordon>

```