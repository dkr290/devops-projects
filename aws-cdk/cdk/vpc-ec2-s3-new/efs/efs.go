package efs

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsefs"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

func CreasteEFS(stack awscdk.Stack, vpc awsec2.Vpc) awsefs.FileSystem {

	fileSystem := awsefs.NewFileSystem(stack, jsii.String("MyEfsFileSystem"), &awsefs.FileSystemProps{
		Vpc:             vpc,
		LifecyclePolicy: awsefs.LifecyclePolicy_AFTER_14_DAYS,
		// files are not transitioned to infrequent access (IA) storage by default
		PerformanceMode: awsefs.PerformanceMode_GENERAL_PURPOSE,
		// default
		OutOfInfrequentAccessPolicy: awsefs.OutOfInfrequentAccessPolicy_AFTER_1_ACCESS,
	})

	// Output the DNS name of the EFS filesystem
	awscdk.NewCfnOutput(stack, aws.String("EfsFileSystemName"), &awscdk.CfnOutputProps{
		Value: fileSystem.PhysicalName(),
	})

	return fileSystem

}
