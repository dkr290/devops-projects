#Create the s3 bucket for kops
```
aws s3api create-bucket --bucket somebucketname --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
```

#Create HA control plane 
```
 export KOPS_STATE_STORE="s3://somebucketname"
 export CONTROL_PLANE_SIZE="t2.medium"
 export NODE_SIZE="t2.medium"
 export ZONES="eu-central-1a,eu-central-1ab,eu-central-1c"
 kops create cluster dev.k8s.local \
  --node-count 3 \
  --zones $ZONES \
  --node-size $NODE_SIZE \
  --control-plane-size $CONTROL_PLANE_SIZE \
  --control-plane-zones $ZONES \ 
  --networking cilium \
  --topology private \
  --bastion="true" \
  --yes
```


#small cluster
```
 # Create a cluster in AWS in a single zone.
  kops create cluster --name=dev.k8s.local \
  --state=s3://my-state-store \
  --zones="eu-central-1a" \
  --control-plane-zones="eu-central-1a" \
  --control-plane-size "t2.medium" \
  --node-size "t2.medium" \
  --node-count=2 \
  --ssh-public-key=kops.pub

```