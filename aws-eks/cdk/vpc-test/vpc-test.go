package main

import (
	"vpc-test/instances"

	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"

	// "github.com/aws/aws-cdk-go/awscdk/v2/awssqs"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type VpcTestStackProps struct {
	awscdk.StackProps
}

var vpc awsec2.Vpc

type Subnets struct {
	Subnet    string
	Zone      string
	CidrBlock string
	IsPublic  bool
}

func AddNames() []Subnets {

	subnets := []Subnets{
		{Subnet: "App1-QA-Web-Pub", Zone: "eu-central-1a", CidrBlock: "192.168.0.0/22", IsPublic: true},
		{Subnet: "App2-QA-Web-Pub", Zone: "eu-central-1b", CidrBlock: "192.168.12.0/22", IsPublic: true},
		{Subnet: "App1-QA-App", Zone: "eu-central-1c", CidrBlock: "192.168.4.0/22", IsPublic: false},
		{Subnet: "App2-QA-App", Zone: "eu-central-1c", CidrBlock: "192.168.16.0/22", IsPublic: false},
		{Subnet: "App1-QA-DB", Zone: "eu-central-1a", CidrBlock: "192.168.8.0/22", IsPublic: false},
		{Subnet: "App2-QA-DB", Zone: "eu-central-1b", CidrBlock: "192.168.20.0/22", IsPublic: false},
	}

	return subnets

}

func NewVpcTestStack(scope constructs.Construct, id string, props *VpcTestStackProps) awscdk.Stack {
	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	vpc = awsec2.NewVpc(stack, aws.String("qa-vpc1"), &awsec2.VpcProps{
		IpAddresses:           awsec2.IpAddresses_Cidr(jsii.String("192.168.0.0/16")),
		MaxAzs:                aws.Float64(0),
		CreateInternetGateway: jsii.Bool(true),
		EnableDnsHostnames:    aws.Bool(true),
		EnableDnsSupport:      aws.Bool(true),
		NatGateways:           aws.Float64(0),
		VpcName:               aws.String("qa-vpc1"),
	})

	// tagsPub := []*awscdk.CfnTag{
	// 	{
	// 		Key:   jsii.String("Name"),
	// 		Value: jsii.String("to-internet"),
	// 	},
	// }

	// tagsPriv := []*awscdk.CfnTag{
	// 	{
	// 		Key:   jsii.String("Name"),
	// 		Value: jsii.String("private"),
	// 	},
	// }
	// RoutingToInternet := awsec2.NewCfnRouteTable(stack, jsii.String("to-internet"), &awsec2.CfnRouteTableProps{
	// 	VpcId: vpc.VpcId(),
	// 	Tags:  &tagsPub,
	// })

	// routInternet := awsec2.NewCfnRoute(stack, jsii.String("Internet-route"), &awsec2.CfnRouteProps{
	// 	RouteTableId:         RoutingToInternet.AttrRouteTableId(),
	// 	DestinationCidrBlock: jsii.String("0.0.0.0/0"),
	// 	GatewayId:            vpc.InternetGatewayId(),
	// })
	// routInternet.AddDependency(RoutingToInternet)

	subnets := AddNames()

	for _, sub := range subnets {

		if sub.IsPublic {

			subnet := awsec2.NewPublicSubnet(stack, jsii.String(sub.Subnet), &awsec2.PublicSubnetProps{
				VpcId:               vpc.VpcId(),
				CidrBlock:           jsii.String(sub.CidrBlock),
				AvailabilityZone:    jsii.String(sub.Zone),
				MapPublicIpOnLaunch: jsii.Bool(sub.IsPublic),
			})

			subnet.AddRoute(jsii.String("to-internet"), &awsec2.AddRouteOptions{
				RouterId:   vpc.InternetGatewayId(),
				RouterType: awsec2.RouterType_GATEWAY,
			})

		} else {
			subnet := awsec2.NewPrivateSubnet(stack, jsii.String(sub.Subnet), &awsec2.PrivateSubnetProps{
				AvailabilityZone:    jsii.String(sub.Zone),
				CidrBlock:           jsii.String(sub.CidrBlock),
				VpcId:               vpc.VpcId(),
				MapPublicIpOnLaunch: jsii.Bool(sub.IsPublic),
			})

			subnet.SubnetId()
		}

	}

	instances.InstanceCreation(stack, vpc)

	return stack
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)

	NewVpcTestStack(app, "VpcTestStack", &VpcTestStackProps{
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
