## Verify kuberconfig

aws eks --region <region-code> update-kubeconfig --name <cluster_name>

## Verify Kubernetes Worker Nodes using kubectl

kubectl get nodes
kubectl get nodes -o wide

## Verify aws-auth configmap

kubectl -n kube-system get configmap aws-auth -o yaml

- it should show something like that

```

k -n kube-system get configmap aws-auth -o yaml
apiVersion: v1
data:
  mapRoles: |
    - "groups":
      - "system:bootstrappers"
      - "system:nodes"
      "rolearn": "arn:aws:iam::xxxxxxxxxxxxx:role/dev_eks_cluster-dev-eks-nodegroup-role"
      "username": "system:node:{{EC2PrivateDNSName}}"
    - "groups":
      - "system:masters"
      "rolearn": "arn:aws:iam::xxxxxxxxxxxxxx:role/eks_admin_role-dev"
      "username": "eks-admin"
  mapUsers: |
    - "groups":
      - "system:masters"
      "userarn": "arn:aws:iam::xxxxxxxxxxxxxxxxxx:user/eksadmin1"
      "username": "eksadmin1"
    - "groups":
      - "system-masters"
      "userarn": "arn:aws:iam::xxxxxxxxxxxxxxxxx:user/eksadmin2"
      "username": "eksadmin2"
kind: ConfigMap

```

## in the IAM Console verify the

- in roles eks_admin_role-dev and verify policy eks-full-access-policy

- eks-full-access-policy in the policies that it has eks-full-access-policy and truest relationshipts
- verify group adn user eksadmin3-dev

# Step-1: Create IAM User Login Profile and User Security Credentials

## Set password for eksadmin3-dev user (verify user exzists in IAM console)

aws iam create-login-profile --user-name eksadmin3-dev --password xxxxxxxxxxxxx --no-password-reset-required

## Create Security Credentials for IAM User and make a note of them

aws iam create-access-key --user-name eksadmin3-dev

# Step-2: Configure eksadmin3-dev user AWS CLI Profile and Set it as Default Profile

## list all configuration data

aws configure list

## list all profile names

aws configure list-profiles

## Configure aws cli eksadmin3-dev Profile

aws configure --profile eksadmin3-dev

## Get current user configured in AWS CLI

aws sts get-caller-identity

## Set default profile

export AWS_DEFAULT_PROFILE=eksadmin3-dev

## Get current user configured in AWS CLI

aws sts get-caller-identity

# Step-3: Assume IAM Role and Configure kubectl

## Export AWS Account ID

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo $ACCOUNT_ID

## Assume IAM Role

aws sts assume-role --role-arn "arn:aws:iam::<REPLACE-YOUR-ACCOUNT-ID>:role/eks_admin_role-dev --role-session-name eksadminsession201

## GET Values and replace here from the above out

export AWS_ACCESS_KEY_ID=RoleAccessKeyID
export AWS_SECRET_ACCESS_KEY=RoleSecretAccessKey
export AWS_SESSION_TOKEN=RoleSessionToken

## Verify current user configured in aws cli

aws sts get-caller-identity

## Clean-Up kubeconfig

```
> $HOME/.kube/config
cat $HOME/.kube/config
```

## Configure kubeconfig for kubectl

aws eks --region <region-code> update-kubeconfig --name <cluster_name>

## describe tjhe cluster

aws eks --region region describe-cluster --name clustername --query cluster.status

## List Kubernetes Nodes

kubectl get nodes
kubectl get pods -n kube-system

## Verify aws-auth configmap after making changes

kubectl -n kube-system get configmap aws-auth -o yaml

# Return back to the default user

## To return to the IAM user, remove the environment variables:

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

## Verify current user configured in aws cli

aws sts get-caller-identity
Observation: It should switch back to current AWS_DEFAULT_PROFILE eksadmin3

# switch back and clen cluster

## Get current user configured in AWS CLI

aws sts get-caller-identity

## Set default profile

export AWS_DEFAULT_PROFILE=default

## Get current user configured in AWS CLI

aws sts get-caller-identity

# Terraform Destroy

terraform apply -destroy -auto-approve
