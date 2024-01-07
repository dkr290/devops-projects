package efs

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsefs"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsiam"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

func CreasteEFS(stack awscdk.Stack, vpc awsec2.Vpc) awsefs.FileSystem {

	np := awsiam.NewPolicyStatement(&awsiam.PolicyStatementProps{
		Effect: awsiam.Effect_ALLOW,
		Actions: &[]*string{
			jsii.String("elasticfilesystem:ClientRootAccess"),
			jsii.String("elasticfilesystem:ClientWrite"),
			jsii.String("elasticfilesystem:ClientMount"),
		},
		Principals: &[]awsiam.IPrincipal{
			awsiam.NewAnyPrincipal(),
		},
		Resources: &[]*string{
			jsii.String("*"),
		},
		Conditions: &map[string]interface{}{
			"Bool": map[string]*string{
				"elasticfilesystem:AccessedViaMountTarget": jsii.String("true"),
			},
		},
	})

	policyDocument := awsiam.NewPolicyDocument(&awsiam.PolicyDocumentProps{
		Statements: &[]awsiam.PolicyStatement{np},
	})

	fileSystem := awsefs.NewFileSystem(stack, jsii.String("MyEfsFileSystem"), &awsefs.FileSystemProps{
		Vpc:             vpc,
		LifecyclePolicy: awsefs.LifecyclePolicy_AFTER_14_DAYS,
		// files are not transitioned to infrequent access (IA) storage by default
		PerformanceMode: awsefs.PerformanceMode_GENERAL_PURPOSE,
		// default
		OutOfInfrequentAccessPolicy: awsefs.OutOfInfrequentAccessPolicy_AFTER_1_ACCESS,
		FileSystemName:              jsii.String("Ec2EFSMount"),
		FileSystemPolicy:            policyDocument,
		EnableAutomaticBackups:      jsii.Bool(false),
	})

	// Output the DNS name of the EFS filesystem
	awscdk.NewCfnOutput(stack, aws.String("EfsFileSystemName"), &awscdk.CfnOutputProps{
		Value: fileSystem.FileSystemId(),
	})

	return fileSystem

}
