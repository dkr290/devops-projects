package main

import (
	"path"

	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awss3assets"
	"github.com/aws/aws-sdk-go-v2/aws"

	// "github.com/aws/aws-cdk-go/awscdk/v2/awssqs"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type VpcPublicStackProps struct {
	awscdk.StackProps
}

var vpcName string = "custom-vpc"
var pVpc awsec2.Vpc

func NewEc2K8sInstances(scope constructs.Construct, id string, props *VpcPublicStackProps) awscdk.Stack {
	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	var amiImage = make(map[string]*string)

	amiImage["eu-central-1"] = jsii.String("ami-04e601abe3e1a910f")

	k8sSG := awsec2.NewSecurityGroup(stack, aws.String("k8sSG"), &awsec2.SecurityGroupProps{
		Vpc:               pVpc,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String("k8sSG"),
	})

	k8sSG.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(22)), aws.String("allow port 22"), aws.Bool(false))
	k8sSG.Connections().AllowFrom(k8sSG, awsec2.NewPort(&awsec2.PortProps{
		Protocol:             awsec2.Protocol_ALL,
		StringRepresentation: aws.String("k8sSG-FromItselfAllow"),
		FromPort:             jsii.Number(0),
		ToPort:               jsii.Number(65535),
	}), aws.String("Allow from k8sSG all"))

	masterAsset := awss3assets.NewAsset(stack, aws.String("install-master-script"), &awss3assets.AssetProps{
		Path: aws.String(path.Join("./", "install_master.sh")),
	})

	workerAsset := awss3assets.NewAsset(stack, aws.String("install-worker_script"), &awss3assets.AssetProps{
		Path: aws.String(path.Join("./", "install_worker.sh")),
	})

	// userdataMaster := awsec2.MultipartUserData_ForLinux(&awsec2.LinuxUserDataOptions{})
	// userdataMaster.AddCommands(aws.String("apt -y update && DEBIAN_FRONTEND=noninteractive apt -y install awscli"))
	// userdataMaster.AddS3DownloadCommand(&awsec2.S3DownloadOptions{
	// 	Bucket:    masterAsset.Bucket(),
	// 	BucketKey: masterAsset.S3ObjectKey(),
	// 	Region:    aws.String("eu-central-1"),
	// })
	// userdataWorker := awsec2.MultipartUserData_ForLinux(&awsec2.LinuxUserDataOptions{})
	// userdataWorker.AddCommands(aws.String("apt -y update && DEBIAN_FRONTEND=noninteractive apt -y install awscli"))
	// userdataWorker.AddS3DownloadCommand(&awsec2.S3DownloadOptions{
	// 	Bucket:    workerAsset.Bucket(),
	// 	BucketKey: workerAsset.S3ObjectKey(),
	// 	Region:    aws.String("eu-central-1"),
	// })

	masterInstance := awsec2.NewInstance(stack, jsii.String("master01"), &awsec2.InstanceProps{
		Vpc:          pVpc,
		InstanceType: awsec2.InstanceType_Of(awsec2.InstanceClass_BURSTABLE2, awsec2.InstanceSize_SMALL),
		MachineImage: awsec2.MachineImage_GenericLinux(
			&amiImage,
			&awsec2.GenericLinuxImageProps{},
		),
		InstanceName:  aws.String("master01"),
		KeyName:       aws.String("ec2-key"),
		SecurityGroup: k8sSG,
		//UserData:      userdataMaster,
	})

	masterAsset.GrantRead(masterInstance.Role())
	masterInstance.UserData().AddCommands(aws.String("apt -y update && DEBIAN_FRONTEND=noninteractive apt -y install awscli"))
	localFile := masterInstance.UserData().AddS3DownloadCommand(&awsec2.S3DownloadOptions{
		Bucket:    masterAsset.Bucket(),
		BucketKey: masterAsset.S3ObjectKey(),
		Region:    aws.String("eu-central-1"),
	})
	masterInstance.UserData().AddExecuteFileCommand(&awsec2.ExecuteFileOptions{
		FilePath: localFile,
	})

	workerInstance := awsec2.NewInstance(stack, jsii.String("worker01"), &awsec2.InstanceProps{
		Vpc:          pVpc,
		InstanceType: awsec2.InstanceType_Of(awsec2.InstanceClass_BURSTABLE2, awsec2.InstanceSize_SMALL),
		MachineImage: awsec2.MachineImage_GenericLinux(
			&amiImage,
			&awsec2.GenericLinuxImageProps{},
		),
		InstanceName:  aws.String("worker01"),
		KeyName:       aws.String("ec2-key"),
		SecurityGroup: k8sSG,
		//UserData:      userdataWorker,
	})

	workerAsset.GrantRead(workerInstance.Role())
	workerInstance.UserData().AddCommands(aws.String("apt -y update && DEBIAN_FRONTEND=noninteractive apt -y install awscli"))
	localFilew := workerInstance.UserData().AddS3DownloadCommand(&awsec2.S3DownloadOptions{
		Bucket:    workerAsset.Bucket(),
		BucketKey: workerAsset.S3ObjectKey(),
		Region:    aws.String("eu-central-1"),
	})
	workerInstance.UserData().AddExecuteFileCommand(&awsec2.ExecuteFileOptions{
		FilePath: localFilew,
	})

	return stack

}

func NewVpcPublicStack(scope constructs.Construct, id string, props *VpcPublicStackProps) awscdk.Stack {
	var sprops awscdk.StackProps
	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	subnetConfiguration := []*awsec2.SubnetConfiguration{
		{
			CidrMask:   aws.Float64(24),
			Name:       aws.String("public"),
			SubnetType: awsec2.SubnetType_PUBLIC,
		},
	}

	pVpc = awsec2.NewVpc(stack, aws.String(vpcName), &awsec2.VpcProps{
		IpAddresses:         awsec2.IpAddresses_Cidr(jsii.String("10.0.0.0/16")),
		MaxAzs:              aws.Float64(2),
		EnableDnsHostnames:  aws.Bool(true),
		EnableDnsSupport:    aws.Bool(true),
		NatGateways:         aws.Float64(0),
		SubnetConfiguration: &subnetConfiguration,
		VpcName:             &vpcName,
	})

	pVpc.VpcArn()

	return stack
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)

	NewVpcPublicStack(app, "VpcPublicStack", &VpcPublicStackProps{
		awscdk.StackProps{
			Env: env(),
		},
	})

	NewEc2K8sInstances(app, "ec2k8sInstance", &VpcPublicStackProps{
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
