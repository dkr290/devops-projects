package main

import (
	"log"
	"os"

	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsautoscaling"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awseks"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsiam"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/joho/godotenv"

	// "github.com/aws/aws-cdk-go/awscdk/v2/awssqs"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type EksStackProps struct {
	awscdk.StackProps
}

var (
	masterUser    string
	masterUserArn string
)

func GetEnvs() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")

	}

	masterUser = os.Getenv("USER_NAME")
	if len(masterUser) == 0 {
		log.Fatal("You must set your 'USER_NAME' environmental variable. See\n\t https://pkg.go.dev/os#Getenv")
	}

	masterUserArn = os.Getenv("USER_ARN")
	if len(masterUserArn) == 0 {
		log.Fatal("You must set your 'USER_ARN' environmental variable. See\n\t https://pkg.go.dev/os#Getenv")
	}

}

func NewEksStack(scope constructs.Construct, id string, props *EksStackProps) awscdk.Stack {
	var sprops awscdk.StackProps

	var role awsiam.Role

	GetEnvs()

	if props != nil {
		sprops = props.StackProps
	}
	stack := awscdk.NewStack(scope, &id, &sprops)

	vpc := awsec2.Vpc_FromLookup(stack, aws.String("VpcStack/eks-vpc"), &awsec2.VpcLookupOptions{
		IsDefault: aws.Bool(false),
		VpcName:   aws.String("VpcStack/eks-vpc"),
	})

	// IAM role for our EC2 worker nodes
	workerRole := awsiam.NewRole(stack, jsii.String("EKSWorkerRole"), &awsiam.RoleProps{
		AssumedBy: awsiam.NewServicePrincipal(jsii.String("ec2.amazonaws.com"), nil),
		RoleName:  jsii.String("EKSWorkerRole"),
	})

	// masterRole := awsiam.NewRole(stack, jsii.String("EKSFullAdminsDEV"), &awsiam.RoleProps{
	// 	Description: aws.String("The Cluster construct will associate this role with the system:masters RBAC group, giving it super-user access to the cluster"),
	// 	AssumedBy:   awsiam.NewServicePrincipal(jsii.String("eks.amazonaws.com"), nil),

	// 	RoleName: jsii.String("EKSFullAdminsDEV"),
	// })

	// newAdminGroup := awsiam.NewGroup(stack, aws.String("EKS-Full-Admins-Dev"), &awsiam.GroupProps{
	// 	GroupName: aws.String("EKS-Full-Admins-Dev"),
	// })

	// policy1 := awsiam.NewPolicyStatement(&awsiam.PolicyStatementProps{
	// 	Actions: &[]*string{
	// 		jsii.String("sts:AssumeRole"),
	// 	},

	// 	Resources: &[]*string{
	// 		masterRole.RoleArn(),
	// 	},
	// })

	// newAdminGroup.AddToPolicy(policy1)

	eksCluster := awseks.NewCluster(stack, jsii.String("eks-dev-cluster"), &awseks.ClusterProps{
		Vpc:                 vpc,
		DefaultCapacity:     jsii.Number(0), // we want to manage capacity our selves
		Version:             awseks.KubernetesVersion_V1_27(),
		ClusterName:         aws.String("eks-dev-cluster"),
		OutputConfigCommand: aws.Bool(true),
		MastersRole:         role,
	})
	eksCluster.AwsAuth().AddUserMapping(awsiam.User_FromUserArn(stack, aws.String(masterUser), aws.String(masterUserArn)), &awseks.AwsAuthMapping{
		Groups: &[]*string{
			jsii.String("system:masters"),
		},
		Username: aws.String(masterUser),
	})

	onDemandASG := awsautoscaling.NewAutoScalingGroup(stack, jsii.String("OnDemandASG"), &awsautoscaling.AutoScalingGroupProps{
		Vpc:          vpc,
		Role:         workerRole,
		MinCapacity:  jsii.Number(1),
		MaxCapacity:  jsii.Number(10),
		InstanceType: awsec2.NewInstanceType(jsii.String("t3.medium")),
		MachineImage: awseks.NewEksOptimizedImage(&awseks.EksOptimizedImageProps{
			KubernetesVersion: jsii.String("1.27"),
			NodeType:          awseks.NodeType_STANDARD,
		}),
		VpcSubnets: &awsec2.SubnetSelection{
			SubnetType: awsec2.SubnetType_PRIVATE_WITH_EGRESS,
		},
	})

	//for managed nodegroup
	//eksCluster.AddNodegroupCapacity()

	eksCluster.ConnectAutoScalingGroupCapacity(onDemandASG, &awseks.AutoScalingGroupOptions{})

	return stack
}

func main() {
	defer jsii.Close()

	app := awscdk.NewApp(nil)

	NewEksStack(app, "EksStack", &EksStackProps{
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
	//return nil

	// Uncomment if you know exactly what account and region you want to deploy
	// the stack to. This is the recommendation for production stacks.
	//---------------------------------------------------------------------------
	// return &awscdk.Environment{
	// 	Account: jsii.String("123456789012"),
	// 	Region:  jsii.String("eu-central-1"),
	// }

	// Uncomment to specialize this stack for the AWS Account and Region that are
	// implied by the current CLI configuration. This is recommended for dev
	// stacks.
	//---------------------------------------------------------------------------
	return &awscdk.Environment{
		Account: jsii.String(os.Getenv("CDK_DEFAULT_ACCOUNT")),
		Region:  jsii.String(os.Getenv("CDK_DEFAULT_REGION")),
	}
}
