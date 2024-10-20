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
