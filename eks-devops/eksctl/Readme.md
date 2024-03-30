#some commands
```
eksctl create cluster -f cluster-01.yaml
```
#to delete the cluster
```
eksctl delete cluster -f cluster.yaml --disable-nodegroup-eviction

```


#update the kubeconfig
```
aws eks update-kubeconfig --region region --name demo-eks-cluster
```


#install latest aws cli

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

```

#only some vpc canges 

```
eksctl utils update-cluster-vpc-config -f cluster.yaml --approve

```

```

eksctl delete cluster $EKS_CLUSTER_NAME --wait

```