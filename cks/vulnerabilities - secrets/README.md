k create secret generic secret1 --from-literal=user=admin1

k create secret generic secret2 --from-literal=user=admin2



# from the node do the following

```
#inspect container and check the env
sudo crictl inspect 571d99ad186a2 | grep user


## get pid 
sudo crictl inspect 571d99ad186a2 | grep pid
ps -eaf | grep 26671

# go to 

sudo su -
cd /proc/26671/root/etc

cat secret1/user


```


## hack into master etcd

ETCDCTL_API3

sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep etcd

sudo ETCDCTL_API=3 etcdctl --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt  --key=/etc/kubernetes/pki/apiserver-etcd-client.key  --cacert=/etc/kubernetes/pki/etcd/ca.crt get /registry/secrets/default/secret1





## encrypt the etcd secrets

https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/