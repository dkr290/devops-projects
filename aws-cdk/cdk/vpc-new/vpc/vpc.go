package vpc

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

func NewVpc(stack awscdk.Stack, vpcName string, cidr string) awsec2.Vpc {
	vpc := awsec2.NewVpc(stack, aws.String(vpcName), &awsec2.VpcProps{
		IpAddresses:           awsec2.IpAddresses_Cidr(jsii.String(cidr)),
		MaxAzs:                aws.Float64(0),
		CreateInternetGateway: jsii.Bool(true),
		EnableDnsHostnames:    aws.Bool(true),
		EnableDnsSupport:      aws.Bool(true),
		NatGateways:           aws.Float64(0),
		VpcName:               aws.String(vpcName),
	})

	return vpc

}

func NewPublicSubnets(stack awscdk.Stack, subnetName, cidrBlock, subnetZone string, vpc awsec2.Vpc) awsec2.PublicSubnet {
	subnet := awsec2.NewPublicSubnet(stack, jsii.String(subnetName), &awsec2.PublicSubnetProps{
		VpcId:               vpc.VpcId(),
		CidrBlock:           jsii.String(cidrBlock),
		AvailabilityZone:    jsii.String(subnetZone),
		MapPublicIpOnLaunch: jsii.Bool(true),
	})

	subnet.AddRoute(jsii.String("to-internet"), &awsec2.AddRouteOptions{
		RouterId:   vpc.InternetGatewayId(),
		RouterType: awsec2.RouterType_GATEWAY,
	})

	return subnet
}
