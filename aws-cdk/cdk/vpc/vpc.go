package main

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsssm"

	// "github.com/aws/aws-cdk-go/awscdk/v2/awssqs"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type VpcStackProps struct {
	awscdk.StackProps
}

func NewVpcStack(scope constructs.Construct, id string, props *VpcStackProps) awscdk.Stack {
	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	// The code that defines your stack goes here

	// example resource
	// queue := awssqs.NewQueue(stack, jsii.String("VpcQueue"), &awssqs.QueueProps{
	// 	VisibilityTimeout: awscdk.Duration_Seconds(jsii.Number(300)),
	// })

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

	eksVpc := awsec2.NewVpc(stack, aws.String("eks-vpc"), &awsec2.VpcProps{
		IpAddresses:         awsec2.IpAddresses_Cidr(jsii.String("10.0.0.0/16")),
		MaxAzs:              aws.Float64(2),
		EnableDnsHostnames:  aws.Bool(true),
		EnableDnsSupport:    aws.Bool(true),
		NatGateways:         aws.Float64(1),
		SubnetConfiguration: &subnetConfiguration,
		VpcName:             aws.String("eks-vpc"),
	})

	awsssm.NewStringParameter(stack, aws.String("eks-vpc-parm"),
		&awsssm.StringParameterProps{
			Description:   aws.String("Created VPC for EKS"),
			ParameterName: aws.String("/network/eks-vpc"),
			StringValue:   eksVpc.VpcId(),
		},
	)

	privSubnets := eksVpc.PrivateSubnets()
	publicSubnets := eksVpc.PublicSubnets()

	for _, p := range *privSubnets {

		awscdk.Tags_Of(p).Add(aws.String("kubernetes.io/role/internal-elb"), aws.String("1"), nil)

	}

	for _, p := range *publicSubnets {
		awscdk.Tags_Of(p).Add(aws.String("kubernetes.io/role/elb"), aws.String("1"), nil)
	}

	return stack
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)

	NewVpcStack(app, "VpcStack", &VpcStackProps{
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
