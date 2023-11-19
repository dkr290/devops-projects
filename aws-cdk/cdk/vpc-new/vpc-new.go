package main

import (
	"vpc-new/nacl"
	"vpc-new/vpc"

	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"

	// "github.com/aws/aws-cdk-go/awscdk/v2/awssqs"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type VpcNewStackProps struct {
	awscdk.StackProps
}

func NewVpcNewStack(scope constructs.Construct, id string, props *VpcNewStackProps) awscdk.Stack {
	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	pVpc := vpc.NewVpc(stack, "qa-vpc", "192.168.0.0/16")
	app1Subnet := vpc.NewPublicSubnets(stack, "App1-QA-App", "192.168.4.0/22", "eu-central-1a", pVpc)
	acl := awsec2.NewNetworkAcl(stack, aws.String("qa-vpc-NACL"), &awsec2.NetworkAclProps{
		Vpc:            pVpc,
		NetworkAclName: aws.String("qa-vpc-NACL"),
	})
	nacl.NaclRules(acl)
	app1Subnet.AssociateNetworkAcl(aws.String("App1-QA-APP-Associate"), acl)

	return stack
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)

	NewVpcNewStack(app, "VpcNewStack", &VpcNewStackProps{
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
