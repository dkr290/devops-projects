package instances

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

// ##
func InstanceCreation(stack awscdk.Stack, vpc awsec2.Vpc) {

	var amiImage = make(map[string]*string)

	amiImage["eu-central-1"] = jsii.String("ami-04e601abe3e1a910f")

	internalSG := awsec2.NewSecurityGroup(stack, aws.String("InternalSG"), &awsec2.SecurityGroupProps{
		Vpc:               vpc,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String("InternalSG"),
	})

	internalSG.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(22)), aws.String("allow port 22"), aws.Bool(false))
	internalSG.Connections().AllowFrom(internalSG, awsec2.NewPort(&awsec2.PortProps{
		Protocol:             awsec2.Protocol_ALL,
		StringRepresentation: aws.String("Internal-FromItselfAllow"),
		FromPort:             jsii.Number(0),
		ToPort:               jsii.Number(65535),
	}), aws.String("Allow from Internal-SG all"))

	type SupplDisk struct {
		DeviceName string
		DeviceSize float64
		VolumeType awsec2.EbsDeviceVolumeType
	}

	type PubInstance struct {
		Name    string
		KeyName string
		SupplDisk
	}

	pubInstances := []PubInstance{
		{Name: "server01-pub", KeyName: "ec2-key", SupplDisk: SupplDisk{DeviceName: "/dev/sdf", DeviceSize: 10, VolumeType: awsec2.EbsDeviceVolumeType_GP3}},
		{Name: "server02-pub", KeyName: "ec2-key", SupplDisk: SupplDisk{DeviceName: "/dev/sdg", DeviceSize: 10, VolumeType: awsec2.EbsDeviceVolumeType_GP3}},
	}

	for _, srv := range pubInstances {
		// creating the block device of 50 GB
		pubEC2BlockDevice := []*awsec2.BlockDevice{
			{

				DeviceName: aws.String(srv.DeviceName),
				Volume: awsec2.BlockDeviceVolume_Ebs(aws.Float64(srv.DeviceSize), &awsec2.EbsDeviceOptions{
					DeleteOnTermination: aws.Bool(true),
					VolumeType:          srv.VolumeType,
				}),
			},
		}

		awsec2.NewInstance(stack, jsii.String(srv.Name), &awsec2.InstanceProps{
			Vpc:          vpc,
			InstanceType: awsec2.InstanceType_Of(awsec2.InstanceClass_BURSTABLE2, awsec2.InstanceSize_SMALL),
			MachineImage: awsec2.MachineImage_GenericLinux(
				&amiImage,
				&awsec2.GenericLinuxImageProps{},
			),
			InstanceName:  aws.String(srv.Name),
			KeyName:       aws.String(srv.KeyName),
			SecurityGroup: internalSG,
			VpcSubnets: &awsec2.SubnetSelection{
				SubnetType: awsec2.SubnetType_PUBLIC,
			},
			// attach additional disk
			BlockDevices: &pubEC2BlockDevice,
		})

	}

}
