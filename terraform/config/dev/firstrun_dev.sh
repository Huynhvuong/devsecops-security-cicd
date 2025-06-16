#!/bin/bash
BUCKETNAME="vuonghuynh-poc-terraform-tfstate-bucket"
REGION="ap-southeast-1"
# Create DynamoDB table to store tfstate lock
DDBTABLENAME="vuonghuynh-poc-tfstate-table"
#Create S3 bucket to store tfstate file with versioning enabled.
aws s3api create-bucket --bucket $REGION-$BUCKETNAME --region $REGION --create-bucket-configuration LocationConstraint=$REGION --profile=vuonghuynh-poc-dev
aws s3api put-bucket-versioning --bucket $REGION-$BUCKETNAME --versioning-configuration Status=Enabled --profile=vuonghuynh-poc-dev
aws dynamodb create-table --table-name $REGION-$DDBTABLENAME --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region $REGION --profile=vuonghuynh-poc-dev
