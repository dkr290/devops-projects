# Get current user configured in AWS CLI

aws sts get-caller-identity

aws eks --region <<region>> update-kubeconfig --name <eks name> --profile default

aws iam create-user --user-name eksadmin2

# Set password for eksadmin1 user

aws iam create-login-profile --user-name eksadmin2 --password <somepassword> --no-password-reset-required

# Create Security Credentials for IAM User and make a note of them

aws iam create-access-key --user-name eksadmin2

# Get IAM User and make a note of arn

aws iam get-user --user-name eksadmin2

kubectl -n kube-system edit configmap aws-auth

```
## mapUsers TEMPLATE - Replaced with IAM User ARN
  mapUsers: |
    - userarn: ARN EKS Admin 1
      username: eksadmin1
      groups:
        - system:masters
    - userarn: ARN EKS Admin 2
      username: eksadmin2
      groups:
        - system:masters
```

kubectl -n kube-system get configmap aws-auth -o yaml

- if it is like that edit it again and remove the line brakes try to format it again
  mapUsers: "- userarn: arn:aws:iam::5064:user/eksadmin1 \n username: eksadmin1\n
  \ groups:\n - system:masters\n- userarn: arn:aws:iam::5064:user/eksadmin2\n
  \ username: eksadmin2\n groups:\n - system:masters\n"
  kind: ConfigMap

# To list all configuration data

aws configure list

# To list all your profile names

aws configure list-profiles

# Configure aws cli eksadmin1 Profile

aws configure --profile eksadmin2

# to list the profiles again

aws configure list-profiles

# Get current user configured in AWS CLI

aws sts get-caller-identity

# Clean-Up kubeconfig

> $HOME/.kube/config
> cat $HOME/.kube/config

# Configure kubeconfig for kubectl with AWS CLI Profile eksadmin2

aws eks --region <region-code> update-kubeconfig --name <cluster_name> --profile <AWS-CLI-Profile-NAME>

- it will fail

## we ned to create the policy full eks policy

aws iam create-policy --policy-name eks-full-access-policy --policy-document file://iam-policy/eks-full-policy.json

## attach the policy to the user eksadmin2

aws iam attach-user-policy --policy-arn <POLICY-ARN> --user-name <USER-NAME>

## again and now it will work

aws eks --region eu-north-1 update-kubeconfig --name eks_cluster --profile eksadmin2
