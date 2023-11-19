package vpcpeering

import (
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

func NewPeering(sourceVPC awsec2.Vpc, destVpc *string, scope constructs.Construct) awsec2.CfnVPCPeeringConnection {

	conf := awsec2.NewCfnVPCPeeringConnection(scope, aws.String("europe-to-asia"), &awsec2.CfnVPCPeeringConnectionProps{
		PeerVpcId:  destVpc,
		VpcId:      sourceVPC.VpcId(),
		PeerRegion: jsii.String("ap-south-1"),
	})

	return conf
}
