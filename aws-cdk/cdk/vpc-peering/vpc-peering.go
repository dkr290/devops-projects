package main

import (
	"fmt"
	"vpc-peering/vpcpeering"

	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"

	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type VpcPeeringStackProps struct {
	awscdk.StackProps
}

type VpcPeeringStackProps2 struct {
	awscdk.StackProps
}

var vpcName1, vpcName2 string = "vpc-central-eu", "vpc-asia"
var pVpc1, pVpc2 awsec2.Vpc

func NewVpcPeeringStack2(scope constructs.Construct, id string, props *VpcPeeringStackProps2) awscdk.Stack {

	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	pVpc2 = vpcpeering.NewVpc(stack, vpcName2, "10.77.0.0/16")
	pVpc2.VpcId()
	defSG := awsec2.NewSecurityGroup(stack, aws.String("Allow-From-Europe-VPC"), &awsec2.SecurityGroupProps{
		Vpc:               pVpc2,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String("Allow-From-Europe-VPC"),
	})

	defSG.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(22)), aws.String("allow port 22"), aws.Bool(false))
	defSG.AddIngressRule(awsec2.Peer_Ipv4(aws.String("172.31.0.0/16")), awsec2.Port_AllTraffic(), aws.String("allow all from VPC Europe"), aws.Bool(false))

	return stack
}

func NewVpcPeeringStack(scope constructs.Construct, id string, props *VpcPeeringStackProps) awscdk.Stack {
	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	pVpc1 = vpcpeering.NewVpc(stack, vpcName1, "172.31.0.0/16")
	fmt.Println(pVpc1.VpcId())

	defSG := awsec2.NewSecurityGroup(stack, aws.String("Allow-To-Asia"), &awsec2.SecurityGroupProps{
		Vpc:               pVpc1,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String("Allow-From-Europe-VPC"),
	})

	defSG.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(22)), aws.String("allow port 22"), aws.Bool(false))
	defSG.AddEgressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_AllTraffic(), aws.String("allow all to internet"), aws.Bool(false))

	vpcpeering.NewPeering(pVpc1, aws.String("vpc-01b578200b6419999"), stack)

	return stack
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)

	NewVpcPeeringStack(app, "VpcPeeringStack", &VpcPeeringStackProps{
		awscdk.StackProps{
			Env: env(),
		},
	})

	NewVpcPeeringStack2(app, "VpcPeeringStack2", &VpcPeeringStackProps2{
		awscdk.StackProps{
			Env: env2(),
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

func env2() *awscdk.Environment {
	// If unspecified, this stack will be "environment-agnostic".
	// Account/Region-dependent features and context lookups will not work, but a
	// single synthesized template can be deployed anywhere.
	//---------------------------------------------------------------------------
	//return nil

	// Uncomment if you know exactly what account and region you want to deploy
	// the stack to. This is the recommendation for production stacks.
	//---------------------------------------------------------------------------
	return &awscdk.Environment{
		//  Account: jsii.String("123456789012"),
		Region: jsii.String("ap-south-1"),
	}

	// Uncomment to specialize this stack for the AWS Account and Region that are
	// implied by the current CLI configuration. This is recommended for dev
	// stacks.
	//---------------------------------------------------------------------------
	// return &awscdk.Environment{
	//  Account: jsii.String(os.Getenv("CDK_DEFAULT_ACCOUNT")),
	//  Region:  jsii.String(os.Getenv("CDK_DEFAULT_REGION")),
	// }
}
