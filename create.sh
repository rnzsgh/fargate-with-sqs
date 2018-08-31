#!/bin/bash

NETWORK_STACK_NAME=base-network

FARGATE_STACK_NAME=batch0

ENV_NAME=prod

# Ensure we have the service linked role created
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com 2> /dev/null

aws cloudformation create-stack  --region us-east-1 --stack-name $NETWORK_STACK_NAME --capabilities CAPABILITY_NAMED_IAM --template-body file://vpc.cfn.yml

aws cloudformation wait stack-create-complete --stack-name $NETWORK_STACK_NAME


# ##############################################################################
# CodeCommit or GitHub

GIT_REPO=sqs-processing-example
GIT_BRANCH=master

# If the repo is a GitHub organization, use that name instead of GitHub user. Leave blank for CodeCommit
GITHUB_USER="CHANGE_ME"

# Credentials for a user who has permission in GitHub organization. Leave blank for CodeCommit
GITHUB_TOKEN="CHANGE_ME"

# ##############################################################################
# Fargate

MIN_CONTAINER=0
MAX_CONTAINER=10
CONTAINER_MEMORY=512
CONTAINER_CPU=256
SCALE_OUT_ADJUSTMENT=10
SCALE_IN_ADJUSTMENT="-5"

aws cloudformation create-stack  --region us-east-1 --stack-name $FARGATE_STACK_NAME --capabilities CAPABILITY_NAMED_IAM --template-body file://fargate.cfn.yml \
  --parameters \
  ParameterKey=EnvironmentName,ParameterValue=$ENV_NAME \
  ParameterKey=NetworkStackName,ParameterValue=$NETWORK_STACK_NAME \
  ParameterKey=GitSourceRepo,ParameterValue=$GIT_REPO \
  ParameterKey=GitBranch,ParameterValue=$GIT_BRANCH \
  ParameterKey=GitHubUser,ParameterValue=$GITHUB_USER \
  ParameterKey=GitHubToken,ParameterValue=$GITHUB_TOKEN \
  ParameterKey=TaskMinContainerCount,ParameterValue=$MIN_CONTAINER \
  ParameterKey=TaskMaxContainerCount,ParameterValue=$MAX_CONTAINER \
  ParameterKey=ServiceSqsScaleOutAdjustment,ParameterValue=$SCALE_OUT_ADJUSTMENT \
  ParameterKey=ServiceSqsScaleInAdjustment,ParameterValue=$SCALE_IN_ADJUSTMENT \
  ParameterKey=ContainerMemory,ParameterValue=$CONTAINER_MEMORY \
  ParameterKey=ContainerCpu,ParameterValue=$CONTAINER_CPU
