package main

import (
	"vpc-deploy/instances"

	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"

	// "github.com/aws/aws-cdk-go/awscdk/v2/awssqs"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type VpcDeployStackProps struct {
	awscdk.StackProps
}

var vpcName string = "custom-vpc"
var pVpc awsec2.Vpc
var instanceCreate = true

func NewVpcDeployStack(scope constructs.Construct, id string, props *VpcDeployStackProps) awscdk.Stack {
	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	subnetConfiguration := []*awsec2.SubnetConfiguration{
		{
			CidrMask:   aws.Float64(24),
			Name:       aws.String("public"),
			SubnetType: awsec2.SubnetType_PUBLIC,
		},
		{
			CidrMask:   aws.Float64(24),
			Name:       aws.String("private"),
			SubnetType: awsec2.SubnetType_PRIVATE_WITH_EGRESS,
		},
	}

	pVpc = awsec2.NewVpc(stack, aws.String(vpcName), &awsec2.VpcProps{
		IpAddresses:         awsec2.IpAddresses_Cidr(jsii.String("10.0.0.0/16")),
		MaxAzs:              aws.Float64(2),
		EnableDnsHostnames:  aws.Bool(true),
		EnableDnsSupport:    aws.Bool(true),
		NatGateways:         aws.Float64(1),
		SubnetConfiguration: &subnetConfiguration,
		VpcName:             &vpcName,
	})

	if instanceCreate {
		instances.InstanceCreation(stack, pVpc)
	}
	pVpc.VpcArn()

	return stack
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)

	NewVpcDeployStack(app, "VpcDeployStack", &VpcDeployStackProps{
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
