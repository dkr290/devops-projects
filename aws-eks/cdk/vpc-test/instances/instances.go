package instances

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

func InstanceCreation(stack awscdk.Stack, vpc awsec2.Vpc) {

	var amiImageEuCentral = make(map[string]*string)
	amiImageEuCentral["eu-central-1"] = jsii.String("ami-04e601abe3e1a910f")

	InstanceSG := awsec2.NewSecurityGroup(stack, aws.String("InstancesSG"), &awsec2.SecurityGroupProps{
		Vpc:               vpc,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String("InstancesSG"),
	})

	awsec2.NewInstance(stack, jsii.String("App1-Pub"), &awsec2.InstanceProps{
		Vpc:          vpc,
		InstanceType: awsec2.InstanceType_Of(awsec2.InstanceClass_BURSTABLE2, awsec2.InstanceSize_SMALL),
		MachineImage: awsec2.MachineImage_GenericLinux(
			&amiImageEuCentral,
			&awsec2.GenericLinuxImageProps{},
		),
		InstanceName:  aws.String("App1-Pub"),
		KeyName:       aws.String("ec2-key"),
		SecurityGroup: InstanceSG,
		VpcSubnets: &awsec2.SubnetSelection{
			Subnets: &[]awsec2.ISubnet{
				awsec2.Subnet_FromSubnetAttributes(stack, aws.String("subnet-05b4cc8cb69d3efc7"), &awsec2.SubnetAttributes{
					SubnetId:         aws.String("subnet-05b4cc8cb69d3efc7"),
					AvailabilityZone: aws.String("eu-central-1a"),
					RouteTableId:     aws.String("rtb-02d16a9b9727fe21e"),
				}),
			},
		},
	})

}
