package main

import (
	"vpc-ec2-lb/instances"
	"vpc-ec2-lb/models"
	"vpc-ec2-lb/vpc"

	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsiam"
	"github.com/aws/aws-sdk-go-v2/aws"

	// "github.com/aws/aws-cdk-go/awscdk/v2/awssqs"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type VpcEc2LbStackProps struct {
	awscdk.StackProps
}

var vpcName string = "custom-vpc"

func NewVpcEc2LbStack(scope constructs.Construct, id string, props *VpcEc2LbStackProps) awscdk.Stack {
	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	// IAM role for s3
	iamFullAccess := awsiam.NewRole(stack, aws.String("Ec2S3Access"), &awsiam.RoleProps{
		AssumedBy: awsiam.NewServicePrincipal(aws.String("ec2.amazonaws.com"), nil),
		RoleName:  aws.String("Ec2S3Access"),
		ManagedPolicies: &[]awsiam.IManagedPolicy{
			awsiam.ManagedPolicy_FromAwsManagedPolicyName(aws.String("AmazonS3FullAccess")), // Attach AmazonS3FullAccess policy
		},
	})

	newVars := models.NewVars(stack)
	vpc := vpc.NewVpc(vpcName, stack)
	instVars := instances.NewInstanceVars(*newVars, vpc)
	instVars.InstanceCreation(iamFullAccess)

	return stack
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)

	NewVpcEc2LbStack(app, "VpcEc2LbStack", &VpcEc2LbStackProps{
		awscdk.StackProps{
			Env: env(),
		},
	})

	app.Synth(nil)
}

// env determines the AWS environment (account+region) in which our stack is to
// be deployed. For more information see: https://docs.aws.amazon.com/cdk/latest/guide/environments.html
func env() *awscdk.Environment {
	// If unspecified, this stack will be "environment-agnostic".
	// Account/Region-dependent features and context lookups will not work, but a
	// single synthesized template can be deployed anywhere.
	//---------------------------------------------------------------------------
	return nil

	// Uncomment if you know exactly what account and region you want to deploy
	// the stack to. This is the recommendation for production stacks.
	//---------------------------------------------------------------------------
	// return &awscdk.Environment{
	//  Account: jsii.String("123456789012"),
	//  Region:  jsii.String("us-east-1"),
	// }

	// Uncomment to specialize this stack for the AWS Account and Region that are
	// implied by the current CLI configuration. This is recommended for dev
	// stacks.
	//---------------------------------------------------------------------------
	// return &awscdk.Environment{
	//  Account: jsii.String(os.Getenv("CDK_DEFAULT_ACCOUNT")),
	//  Region:  jsii.String(os.Getenv("CDK_DEFAULT_REGION")),
	// }
}
