package models

import (
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/aws-cdk-go/awscdk/v2/awsiam"
)

type StackVars struct {
	Stack awscdk.Stack
}

type Commonstacks interface {
	InstanceCreation(iamRole awsiam.Role)
}

func NewVars(s awscdk.Stack) *StackVars {
	return &StackVars{
		Stack: s,
	}
}
