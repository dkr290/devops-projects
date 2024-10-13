# Create IAM User

aws iam create-user --user-name eksadmin1

# Attach AdministratorAccess Policy to User

aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --user-name eksadmin1

# Set password for eksadmin1 user

aws iam create-login-profile --user-name eksadmin1 --password @EKSUser101 --no-password-reset-required

# Create Security Credentials for IAM User and make a note of them

aws iam create-access-key --user-name eksadmin1

# Make a note of Access Key ID and Secret Access Key

```json
User: eksadmin1
{
 "AccessKey": {
 "UserName": "eksadmin1",
 "AccessKeyId": "IDxxxxx",
 "Status": "Active",
 "SecretAccessKey": "<some password>",
 "CreateDate": "2022-03-20T03:19:02+00:00"
 }
}
```

# To list all configuration data

aws configure list

# To list all your profile names

aws configure list-profiles

# Configure aws cli eksadmin1 Profile

aws configure --profile eksadmin1
AWS Access Key ID:
AWS Secret Access Key:
Default region: eu-north-1
Default output format: json

# Get current user configured in AWS CLI

aws sts get-caller-identity

# Clean-Up kubeconfig

cat $HOME/.kube/config

> $HOME/.kube/config
> cat $HOME/.kube/config

# Configure kubeconfig for eksadmin1 AWS CLI profile

aws eks --region <<region>> update-kubeconfig --name <eks name> --profile eksadmin1

# Verify kubeconfig file

cat $HOME/.kube/config
env: - name: AWS_PROFILE
value: eksadmin1

# Verify Kubernetes Nodes

kubectl get nodes
Observation:

1. We should fail in accessing the EKS Cluster resources using kubectl

# Error / Warning

Your current user or role does not have access to Kubernetes objects on this EKS cluster
This may be due to the current user or role not having Kubernetes RBAC permissions to describe cluster resources or

# Review aws config map

# Verify aws-auth config map before making changes

- Switch to the default account
  kubectl -n kube-system get configmap aws-auth -o yaml
  Observation: Currently, eksadmin1 is configured as AWS CLI default profile, switch back to default profile.

# Configure kubeconfig for default AWS CLI profile (Switch back to EKS_Cluster_Create_User to perform these steps)

aws eks --region eu-central-1 update-kubeconfig --name "clustername"
[or]
aws eks --region eu-central-1 update-kubeconfig --name "clustername" --profile default

# Verify aws-auth config map before making changes

kubectl -n kube-system get configmap aws-auth -o yaml

# Get IAM User and make a note of arn

aws iam get-user --user-name eksadmin1

# To edit configmap

kubectl -n kube-system edit configmap aws-auth

## mapUsers TEMPLATE (Add this under "data")

```yaml
mapUsers: |

  - userarn: <REPLACE WITH USER ARN>
    username: eksadmin1
    groups:
      - system:masters
```

# Verify Nodes if they are ready (only if any errors occured during update)

kubectl get nodes --watch

# Verify aws-auth config map after making changes

kubectl -n kube-system get configmap aws-auth -o yaml

# Clean-Up kubeconfig

> $HOME/.kube/config
> cat $HOME/.kube/config

# Configure kubeconfig for eksadmin1 AWS CLI profile

aws eks --region us-east-1 update-kubeconfig --name eksdemo1 --profile eksadmin1

# Verify kubeconfig file

cat $HOME/.kube/config
env: - name: AWS_PROFILE
value: eksadmin1

# Verify Kubernetes Nodes

kubectl get nodes
