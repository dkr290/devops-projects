package vpc

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

func NewVpc(vpcName string, stack awscdk.Stack) awsec2.Vpc {
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

	pVpc := awsec2.NewVpc(stack, aws.String(vpcName), &awsec2.VpcProps{
		IpAddresses:         awsec2.IpAddresses_Cidr(jsii.String("10.0.0.0/16")),
		MaxAzs:              aws.Float64(2),
		EnableDnsHostnames:  aws.Bool(true),
		EnableDnsSupport:    aws.Bool(true),
		NatGateways:         aws.Float64(0),
		SubnetConfiguration: &subnetConfiguration,
		VpcName:             &vpcName,
	})

	return pVpc

}
