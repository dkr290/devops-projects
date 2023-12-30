package s3b

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awss3"
	"github.com/aws/aws-sdk-go-v2/aws"
)

// Create an S3 bucket

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

	bucket := awss3.NewBucket(stack, aws.String("thisistestbucket20fgb"), &awss3.BucketProps{

		BucketName:        aws.String("thisistestbucket20fgb"),
		Versioned:         aws.Bool(true), // Enable versioning
		PublicReadAccess:  aws.Bool(false),
		AutoDeleteObjects: aws.Bool(true),
		RemovalPolicy:     awscdk.RemovalPolicy_DESTROY,

		LifecycleRules: &lifeCycleRule1,
	})

	awscdk.NewCfnOutput(stack, aws.String("MyS3BucketOutput"), &awscdk.CfnOutputProps{
		Value: bucket.BucketName(),
	})

	replbucket := awss3.NewBucket(stack, aws.String("thisisreplicabucket20fgb"), &awss3.BucketProps{

		BucketName:        aws.String("thisisreplicabucket20fgb"),
		Versioned:         aws.Bool(true), // Enable versioning
		PublicReadAccess:  aws.Bool(false),
		AutoDeleteObjects: aws.Bool(true),
		RemovalPolicy:     awscdk.RemovalPolicy_DESTROY,

		LifecycleRules: &lifeCycleRule1,
	})

	awscdk.NewCfnOutput(stack, aws.String("MyS3ReplicaBucketOutput"), &awscdk.CfnOutputProps{

		Value: replbucket.BucketName(),
	})

	//IAM role for replication
	// replicationRole := awsiam.NewRole(stack, aws.String("ReplicationRole"), &awsiam.RoleProps{
	// 	AssumedBy: awsiam.NewServicePrincipal(aws.String("s3.amazonaws.com"), nil),
	// })

	// replicationConfig := awss3.CfnBucket_ReplicationConfigurationProperty{
	// 	Role: replicationRole,
	// 	Rules: []awss3.CfnBucket_ReplicationRuleProperty{
	// 		{
	// 			Destination: &awss3.CfnBucket_ReplicationDestinationProperty{
	// 				Bucket: replbucket.BucketName(),
	// 			},
	// 			Status:   aws.String("Enabled"),
	// 			Priority: aws.Float64(1),
	// 			DeleteMarkerReplication: &awss3.CfnBucket_DeleteMarkerReplicationProperty{
	// 				Status: aws.String("Enabled"),
	// 			},
	// 		},
	// 	},
	// }

}
