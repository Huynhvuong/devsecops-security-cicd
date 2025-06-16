#!/bin/bash

echo "#########################################################"
echo "#     Terraform Initialization for Vuonghuynh-poc       #"
echo "#########################################################"
echo ""

BUCKETNAME="vuonghuynh-poc-terraform-tfstate-bucket"
REGION="ap-southeast-1"
DDBTABLENAME="vuonghuynh-poc-tfstate-table"
PROFILE="vuonghuynh-poc-dev"
PROJECT_NAME="vuonghuynh-poc"

terraform init -upgrade -reconfigure -backend=true -backend-config="bucket=$REGION-$BUCKETNAME" -backend-config="key=$PROJECT_NAME/terraform.tfstate" -backend-config="region=$REGION" -backend-config="profile=$PROFILE" -backend-config="dynamodb_table=$REGION-$DDBTABLENAME"
terraform workspace select dev
