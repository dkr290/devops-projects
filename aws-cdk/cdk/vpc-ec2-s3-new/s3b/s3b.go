package s3b

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsiam"
	"github.com/aws/aws-cdk-go/awscdk/v2/awss3"
	"github.com/aws/aws-sdk-go-v2/aws"
)

// Create an S3 bucket

func ReplicationS3Config(stack awscdk.Stack) {

	rbucket := awss3.NewCfnBucket(stack, aws.String("thisistestreoplicabucket49f"), &awss3.CfnBucketProps{
		BucketName: aws.String("thisistestreoplicabucket49f"),
		VersioningConfiguration: awss3.CfnBucket_VersioningConfigurationProperty{
			Status: aws.String("Enabled"),
		},
	})

	//IAM role for replication
	replicationRole := awsiam.NewRole(stack, aws.String("S3ReplicationRole"), &awsiam.RoleProps{
		AssumedBy: awsiam.NewServicePrincipal(aws.String("s3.amazonaws.com"), nil),
		RoleName:  aws.String("S3ReplicationRole"),
		ManagedPolicies: &[]awsiam.IManagedPolicy{
			awsiam.ManagedPolicy_FromAwsManagedPolicyName(aws.String("AmazonS3FullAccess")), // Attach AmazonS3FullAccess policy
		},
	})

	replicationConfig := awss3.CfnBucket_ReplicationConfigurationProperty{
		Role: replicationRole.RoleArn(),
		Rules: []awss3.CfnBucket_ReplicationRuleProperty{
			{
				Destination: &awss3.CfnBucket_ReplicationDestinationProperty{
					Bucket: rbucket.BucketName(),
				},
				Status:   aws.String("Enabled"),
				Priority: aws.Float64(1),
				DeleteMarkerReplication: &awss3.CfnBucket_DeleteMarkerReplicationProperty{
					Status: aws.String("Enabled"),
				},
			},
		},
	}

	bucket := awss3.NewCfnBucket(stack, aws.String("thisistestbucket20fgb"), &awss3.CfnBucketProps{
		BucketName: aws.String("thisistestbucket20fgb"),
		VersioningConfiguration: awss3.CfnBucket_VersioningConfigurationProperty{
			Status: aws.String("Enabled"),
		},

		ReplicationConfiguration: replicationConfig,
	})

	awscdk.NewCfnOutput(stack, aws.String("MyS3BucketOutput"), &awscdk.CfnOutputProps{
		Value: bucket.BucketName(),
	})

	awscdk.NewCfnOutput(stack, aws.String("MyS3ReplicaBucketOutput"), &awscdk.CfnOutputProps{

		Value: rbucket.BucketName(),
	})
}

func S3Creation(stack awscdk.Stack) {

	lifeCycleRule1 := []*awss3.LifecycleRule{

		{
			Id:      aws.String("Rule1"),
			Enabled: aws.Bool(true),
			Transitions: &[]*awss3.Transition{
				{
					StorageClass:    awss3.StorageClass_INFREQUENT_ACCESS(),
					TransitionAfter: awscdk.Duration_Days(aws.Float64(30)),
				},
				{
					StorageClass:    awss3.StorageClass_GLACIER_INSTANT_RETRIEVAL(),
					TransitionAfter: awscdk.Duration_Days(aws.Float64(60)),
				},
			},
		},
	}

	bucket_another := awss3.NewBucket(stack, aws.String("thisisanother21fgb"), &awss3.BucketProps{

		BucketName:        aws.String("thisisanotherbucket21fgb"),
		Versioned:         aws.Bool(true), // Enable versioning
		PublicReadAccess:  aws.Bool(false),
		AutoDeleteObjects: aws.Bool(true),
		RemovalPolicy:     awscdk.RemovalPolicy_DESTROY,
		ObjectLockEnabled: aws.Bool(false),

		LifecycleRules: &lifeCycleRule1,
	})

	awscdk.NewCfnOutput(stack, aws.String("MyS3AnotherBucketOutput"), &awscdk.CfnOutputProps{

		Value: bucket_another.BucketName(),
	})

}
