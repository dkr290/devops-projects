package instances

import (
	"path"
	"vpc-ec2-lb/models"

	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsiam"
	"github.com/aws/aws-cdk-go/awscdk/v2/awss3assets"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

type CommonStructs struct {
	StackVars models.StackVars
	vpc       awsec2.Vpc
}

func NewInstanceVars(uSt models.StackVars, vpc awsec2.Vpc) *CommonStructs {
	return &CommonStructs{
		StackVars: uSt,
		vpc:       vpc,
	}
}
func (m *CommonStructs) InstanceCreation(iamRole awsiam.Role) {

	var amiImage = make(map[string]*string)

	amiImage["eu-central-1"] = jsii.String("ami-04e601abe3e1a910f")

	internalSG := awsec2.NewSecurityGroup(m.StackVars.Stack, aws.String("InternalSG"), &awsec2.SecurityGroupProps{
		Vpc:               m.vpc,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String("InternalSG"),
	})

	internalSG.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(22)), aws.String("allow port 22"), aws.Bool(false))
	internalSG.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(80)), aws.String("allow port 80"), aws.Bool(false))
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
		asset   awss3assets.Asset
		SupplDisk
	}

	theAsset1 := awss3assets.NewAsset(m.StackVars.Stack, aws.String("install-script1"), &awss3assets.AssetProps{
		Path: aws.String(path.Join("./", "install_webserver1.sh")),
	})
	theAsset2 := awss3assets.NewAsset(m.StackVars.Stack, aws.String("install-script2"), &awss3assets.AssetProps{
		Path: aws.String(path.Join("./", "install_webserver2.sh")),
	})

	pubInstances := []PubInstance{
		{Name: "server01-pub", KeyName: "ec2-key2", asset: theAsset1, SupplDisk: SupplDisk{DeviceName: "/dev/sdf", DeviceSize: 10, VolumeType: awsec2.EbsDeviceVolumeType_GP3}},
		{Name: "server02-pub", KeyName: "ec2-key2", asset: theAsset2, SupplDisk: SupplDisk{DeviceName: "/dev/sdg", DeviceSize: 10, VolumeType: awsec2.EbsDeviceVolumeType_GP3}},
	}

	var allInstances []awsec2.Instance
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

		allInstances = append(allInstances, awsec2.NewInstance(m.StackVars.Stack, jsii.String(srv.Name), &awsec2.InstanceProps{
			Vpc:          m.vpc,
			InstanceType: awsec2.InstanceType_Of(awsec2.InstanceClass_BURSTABLE2, awsec2.InstanceSize_MICRO),
			Role:         iamRole,
			MachineImage: awsec2.MachineImage_GenericLinux(
				&amiImage,
				&awsec2.GenericLinuxImageProps{},
			),
			InstanceName: aws.String(srv.Name),
			KeyName:      aws.String(srv.KeyName),
			//KeyPair:       awsec2.KeyPair_FromKeyPairName(stack, aws.String("ec2KeyPair"+strconv.Itoa(i)), &srv.KeyName),
			SecurityGroup: internalSG,
			VpcSubnets: &awsec2.SubnetSelection{
				SubnetType: awsec2.SubnetType_PUBLIC,
			},
			// attach additional disk
			BlockDevices: &pubEC2BlockDevice,
		}))

	}

	for i, ins := range allInstances {
		switch i {
		case 0:
			grantAsset(theAsset1, ins)

		case 1:
			grantAsset(theAsset2, ins)
		}

	}

}

func grantAsset(theAsset awss3assets.Asset, ins awsec2.Instance) {
	theAsset.GrantRead(ins.Role())
	ins.UserData().AddCommands(aws.String("apt -y update && DEBIAN_FRONTEND=noninteractive apt -y install awscli"))
	localFile := ins.UserData().AddS3DownloadCommand(&awsec2.S3DownloadOptions{
		Bucket:    theAsset.Bucket(),
		BucketKey: theAsset.S3ObjectKey(),
		Region:    aws.String("eu-central-1"),
	})
	ins.UserData().AddExecuteFileCommand(&awsec2.ExecuteFileOptions{
		FilePath: localFile,
	})
}
