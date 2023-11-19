package nacl

import (
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	"github.com/aws/aws-sdk-go-v2/aws"
)

func NaclRules(acl awsec2.NetworkAcl) {
	acl.AddEntry(aws.String("default-allow"), &awsec2.CommonNetworkAclEntryOptions{
		Cidr:       awsec2.AclCidr_AnyIpv4(),
		RuleNumber: aws.Float64(100),
		Traffic:    awsec2.AclTraffic_AllTraffic(),
		Direction:  awsec2.TrafficDirection_EGRESS,
	})
	acl.AddEntry(aws.String("default-allow-ingress"), &awsec2.CommonNetworkAclEntryOptions{
		Cidr:       awsec2.AclCidr_AnyIpv4(),
		RuleNumber: aws.Float64(100),
		Traffic:    awsec2.AclTraffic_AllTraffic(),
		Direction:  awsec2.TrafficDirection_INGRESS,
	})
}
