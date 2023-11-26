package instance

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

type LocalStack struct {
	Stack     awscdk.Stack
	CommonVPC awsec2.Vpc
}

func NewInstanceStack(s awscdk.Stack, vpc awsec2.Vpc) *LocalStack {
	return &LocalStack{
		Stack:     s,
		CommonVPC: vpc,
	}
}

func (s *LocalStack) NewInstance(name string, sgIngress map[string]map[string]int, amiImage map[string]*string, pSubnet awsec2.PublicSubnet) {

	// instanceSG.Connections().AllowFrom(instanceSG, awsec2.NewPort(&awsec2.PortProps{
	// 	Protocol:             awsec2.Protocol_ALL,
	// 	StringRepresentation: aws.String("k8sSG-FromItselfAllow"),
	// 	FromPort:             jsii.Number(0),
	// 	ToPort:               jsii.Number(65535),
	// }), aws.String("Allow from instanceSG all"))

	importedSubnet := awsec2.Subnet_FromSubnetAttributes(s.CommonVPC, aws.String("ImportedSubnet"), &awsec2.SubnetAttributes{
		SubnetId:         pSubnet.SubnetId(),
		AvailabilityZone: pSubnet.AvailabilityZone(),
	})

	masterInstance := awsec2.NewInstance(s.Stack, jsii.String(name), &awsec2.InstanceProps{
		Vpc:          s.CommonVPC,
		InstanceType: awsec2.InstanceType_Of(awsec2.InstanceClass_BURSTABLE2, awsec2.InstanceSize_SMALL),
		MachineImage: awsec2.MachineImage_GenericLinux(
			&amiImage,
			&awsec2.GenericLinuxImageProps{},
		),
		InstanceName: aws.String(name),
		KeyName:      aws.String("ec2-key"),
		VpcSubnets: &awsec2.SubnetSelection{
			Subnets: &[]awsec2.ISubnet{importedSubnet},
		},
	})
	for k, v := range sgIngress {
		sg := s.ingressRules(k, v)
		masterInstance.AddSecurityGroup(sg)
	}

	masterInstance.UserData().AddCommands(aws.String("apt -y update && DEBIAN_FRONTEND=noninteractive apt -y install awscli"))

}

func (s *LocalStack) ingressRules(sGname string, rules map[string]int) awsec2.SecurityGroup {

	sg := awsec2.NewSecurityGroup(s.Stack, aws.String(sGname), &awsec2.SecurityGroupProps{
		Vpc:               s.CommonVPC,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String(sGname),
	})

	for rulename, port := range rules {

		sg.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(port)), aws.String(rulename), aws.Bool(false))
	}

	return sg
}
