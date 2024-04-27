- create iam user developer
- aws configure --profile developer
- k edit cm aws-auth -n kube-system
  mapUsers: |  
   ┊ ┊ - userArn: <userarn>  
   ┊ ┊ ┊ username: developer  
   ┊ ┊ ┊ groups:  
   ┊ ┊ ┊ - reader
- the following policy is needed for development user this is for the user to interract with AWS and eks cluster
  {
  "Version": "2012-10-17",
  "Statement": [
  {
  "Effect": "Allow",
  "Action": [
  "eks:DescribeNodegroup",
  "eks:ListNodegroups",
  "eks:DescribeCluster",
  "eks:ListClusters",
  "eks:AccessKubernetesApi",
  "ssm:GetParameter",
  "eks:ListUpdates",
  "eks:ListFargateProfiles"
  ],
  "Resource": "\*"
  }
  ]
  }
  aws eks update-kubeconfig --region eu-central-1 --name demo-eks-cluster01 --profile developer
  aws eks update-kubeconfig --region eu-central-1 --name demo-eks-cluster01 --profile default

- to test what developer can do
  k can-i get secrets
  k can-i create configmaps
  k can-i get deployments

- so for groups no need to modify the configmap just to assume the role
  it needs to asume the role, in edit of the policy we need also assume  
  aws sts assume-role \
  --role-arn <arn> (example eks-admin)\
  --role-session-name manager-session \
  --profile developer
