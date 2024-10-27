# create IAM Role, IAM Trust Policy and IAM Policy

## Verify User (Ensure you are using AWS Admin)

aws sts get-caller-identity

## Export AWS Account ID

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo $ACCOUNT_ID

## IAM Trust Policy

POLICY=$(echo -n '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':root"},"Action":"sts:AssumeRole","Condition":{}}]}')

## Verify both values

echo ACCOUNT_ID=$ACCOUNT_ID
echo POLICY=$POLICY

## Create IAM Role

aws iam create-role \
 --role-name eks-admin-role \
 --description "Kubernetes administrator role (for AWS IAM Authenticator for Kubernetes)." \
 --assume-role-policy-document "$POLICY" \
 --output text \
 --query 'Role.Arn'

## Create IAM Policy - EKS Full access

cd iam-files
aws iam put-role-policy --role-name eks-admin-role --policy-name eks-full-access-policy --policy-document file://eks-full-access-policy.json

## Create iam group name eksadmins

aws iam create-group --group-name eksadmins

# add group policy to the eksadmins

## Verify AWS ACCOUNT_ID is set

echo $ACCOUNT_ID

## IAM Group Policy

ADMIN_GROUP_POLICY=$(echo -n '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeOrganizationAccountRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':role/eks-admin-role"
}
]
}')

## Verify Policy (if AWS Account Id replaced in policy)

echo $ADMIN_GROUP_POLICY

## Create Policy

aws iam put-group-policy \
--group-name eksadmins \
--policy-name eksadmins-group-policy \
--policy-document "$ADMIN_GROUP_POLICY"

# Gives Access to our IAM Roles in EKS Cluster

## Verify aws-auth configmap before making changes

kubectl -n kube-system get configmap aws-auth -o yaml

## Edit aws-auth configmap

kubectl -n kube-system edit configmap aws-auth

## ADD THIS in data -> mapRoles section of your aws-auth configmap

## Replace ACCOUNT_ID and EKS-ADMIN-ROLE

    - rolearn: arn:aws:iam::<ACCOUNT_ID>:role/<EKS-ADMIN-ROLE>
      username: eks-admin
      groups:
        - system:masters

# Create users in was

## Create IAM User

aws iam create-user --user-name eksadmin1

## Associate IAM User to IAM Group eksadmins

aws iam add-user-to-group --group-name <GROUP> --user-name <USER>
aws iam add-user-to-group --group-name eksadmins --user-name eksadmin1

## Set password for eksadmin1 user

aws iam create-login-profile --user-name eksadmin1 --password <some password> --no-password-reset-required

## Create Security Credentials for IAM User and make a note of them

aws iam create-access-key --user-name eksadmin1

# Configure AWS eksadmin1 profile

## To list all configuration data

aws configure list

## To list all your profile names

aws configure list-profiles

# Configure aws cli eksadmin1 Profile

aws configure --profile eksadmin1
AWS Access Key ID:
AWS Secret Access Key:
Default region: <region>
Default output format: json

## Get current user configured in AWS CLI

aws sts get-caller-identity

- should be the default account created EKS
-

## Set default profile

export AWS_DEFAULT_PROFILE=eksadmin1

## Get current user configured in AWS CLI

aws sts get-caller-identity
Observation: Should the user "eksadmin1"

## Clean-Up kubeconfig

```
> $HOME/.kube/config
cat $HOME/.kube/config
```

## Configure kubeconfig for kubectl

aws eks --region <region-code> update-kubeconfig --name <cluster_name>

what is happening
An error occurred (AccessDeniedException) when calling the DescribeCluster operation: User: arn:aws:iam::xxxxxxxx:user/eksadmin1
is not authorized to perform: eks:DescribeCluster on resource:

# Assume IAM Role and Configure kubectl

## Export AWS Account ID

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo $ACCOUNT_ID

## Assume IAM Role

aws sts assume-role --role-arn "arn:aws:iam::<REPLACE-YOUR-ACCOUNT-ID>:role/eks-admin-role" --role-session-name eksadminsession01
aws sts assume-role --role-arn "arn:aws:iam::$ACCOUNT_ID:role/eks-admin-role" --role-session-name eksadminsession101

## GET Values and replace here

export AWS_ACCESS_KEY_ID=RoleAccessKeyID
export AWS_SECRET_ACCESS_KEY=RoleSecretAccessKey
export AWS_SESSION_TOKEN=RoleSessionToken

## verify and it is different

aws sts get-caller-identity

## do again

```
# Clean-Up kubeconfig
>$HOME/.kube/config
cat $HOME/.kube/config

# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
after that
k get nodes
k get pods -n kube-system
```

## To return to the IAM user, remove the environment variables:

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
Then it will be unauthorized

## the assume one can be done through web interface as well adding account id and assume role eks-admin-role

## in web console

# Cleanup

## Get current user configured in AWS CLI

aws sts get-caller-identity
Observation: Should the user "eksadmin1" from eksadmin1 profile

## Set default profile

export AWS_DEFAULT_PROFILE=default

## Get current user configured in AWS CLI

aws sts get-caller-identity
Should be this time the initial account

## Delete IAM Role Policy and IAM Role

aws iam delete-role-policy --role-name eks-admin-role --policy-name eks-full-access-policy
aws iam delete-role --role-name eks-admin-role

## Remove IAM User from IAM Group

aws iam remove-user-from-group --user-name eksadmin1 --group-name eksadmins

## Delete IAM User Login profile

aws iam delete-login-profile --user-name eksadmin1

## Delete IAM Access Keys

aws iam list-access-keys --user-name eksadmin1
aws iam delete-access-key --access-key-id <REPLACE AccessKeyId> --user-name eksadmin1

## Delete IAM user

aws iam delete-user --user-name eksadmin1

## Delete IAM Group Policy

aws iam delete-group-policy --group-name eksadmins --policy-name eksadmins-group-policy

## Delete IAM Group

aws iam delete-group --group-name eksadmins
Cleanup - EKS Cluster

## Terraform Destroy
