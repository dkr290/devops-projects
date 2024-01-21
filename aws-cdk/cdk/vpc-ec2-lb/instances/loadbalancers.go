package instances

import (
	"github.com/aws/aws-cdk-go/awscdk/v2/awsec2"
	elbv2 "github.com/aws/aws-cdk-go/awscdk/v2/awselasticloadbalancingv2"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/jsii-runtime-go"
)

func (m *CommonStructs) NetLB() (elbv2.NetworkLoadBalancer, elbv2.NetworkListener) {

	// lb := elbv2.NewApplicationLoadBalancer(m.StackVars.Stack, aws.String("calssuc-lb1"), &elbv2.ApplicationLoadBalancerProps{
	// 	LoadBalancerName: aws.String("custom-lb1"),
	// 	Vpc:              m.vpc,
	// 	InternetFacing:   aws.Bool(true),
	// })

	lbSG := awsec2.NewSecurityGroup(m.StackVars.Stack, aws.String("LbSG"), &awsec2.SecurityGroupProps{
		Vpc:               m.vpc,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String("LbSG"),
	})

	lbSG.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(80)), aws.String("allow port 80"), aws.Bool(false))

	nlbProps := elbv2.NetworkLoadBalancerProps{
		LoadBalancerName: aws.String("network-lb1"),
		Vpc:              m.vpc,
		InternetFacing:   aws.Bool(true),
		SecurityGroups:   &[]awsec2.ISecurityGroup{lbSG},
	}

	lb := elbv2.NewNetworkLoadBalancer(m.StackVars.Stack, aws.String("network-lb1"), &nlbProps)
	targetGroup := elbv2.NewNetworkTargetGroup(m.StackVars.Stack, aws.String("lb-TG"), &elbv2.NetworkTargetGroupProps{
		TargetGroupName: aws.String("lb-TG"),
		HealthCheck:     &elbv2.HealthCheck{Port: aws.String("80")},
		TargetType:      elbv2.TargetType_INSTANCE,
		Protocol:        elbv2.Protocol_TCP,
		Port:            aws.Float64(80),
		Vpc:             m.vpc,
	})
	list := lb.AddListener(aws.String("lb-listener"), &elbv2.BaseNetworkListenerProps{
		Port:                aws.Float64(80),
		DefaultTargetGroups: &[]elbv2.INetworkTargetGroup{targetGroup},
		Protocol:            elbv2.Protocol_TCP,
	})

	return lb, list

}

func (m *CommonStructs) NetALB(instances []awsec2.Instance) {

	lbSG := awsec2.NewSecurityGroup(m.StackVars.Stack, aws.String("LbSG"), &awsec2.SecurityGroupProps{
		Vpc:               m.vpc,
		AllowAllOutbound:  aws.Bool(true),
		SecurityGroupName: aws.String("LbSG"),
	})

	lbSG.AddIngressRule(awsec2.Peer_AnyIpv4(), awsec2.Port_Tcp(jsii.Number(80)), aws.String("allow port 80"), aws.Bool(false))

	lb := elbv2.NewApplicationLoadBalancer(m.StackVars.Stack, aws.String("alb-lb1"), &elbv2.ApplicationLoadBalancerProps{
		LoadBalancerName: aws.String("alb-lb1"),
		Vpc:              m.vpc,
		InternetFacing:   aws.Bool(true),
		SecurityGroup:    lbSG,
	})
	targetGroup := elbv2.NewApplicationTargetGroup(m.StackVars.Stack, aws.String("lb-TG"), &elbv2.ApplicationTargetGroupProps{
		TargetGroupName: aws.String("lb-TG"),
		HealthCheck:     &elbv2.HealthCheck{Port: aws.String("80")},
		TargetType:      elbv2.TargetType_INSTANCE,
		Port:            aws.Float64(80),
		Vpc:             m.vpc,

		Targets: &[]elbv2.IApplicationLoadBalancerTarget{},
	})

	list := lb.AddListener(aws.String("lb-listener"), &elbv2.BaseApplicationListenerProps{
		Port:                aws.Float64(80),
		DefaultTargetGroups: &[]elbv2.IApplicationTargetGroup{targetGroup},
	})
	//example to do fixed response rule
	list.AddAction(aws.String("curl response"), &elbv2.AddApplicationActionProps{
		Priority: jsii.Number(10),
		Conditions: &[]elbv2.ListenerCondition{
			elbv2.ListenerCondition_HttpHeader(aws.String("User-Agent"), &[]*string{
				aws.String("*curl*"),
				aws.String("(Mozilla*"),
				aws.String("*Chrome*"),
			}),
		},

		Action: elbv2.ListenerAction_FixedResponse(jsii.Number(200), &elbv2.FixedResponseOptions{
			ContentType: jsii.String("text/plain"),
			MessageBody: jsii.String("Hi Curl"),
		}),
	})

}
