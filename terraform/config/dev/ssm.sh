#!/bin/bash

# aws ssm put-parameter --name "/vuonghuynh-poc/dev/AppTaskCPU" --value "512" --type "String" --overwrite --region ap-southeast-1
# aws ssm put-parameter --name "/vuonghuynh-poc/dev/AppTaskMemory" --value "1024" --type "String" --overwrite --region ap-southeast-1
# aws ssm put-parameter --name "/vuonghuynh-poc/dev/AppCpuHardLimit" --value "256" --type "String" --overwrite --region ap-southeast-1
# aws ssm put-parameter --name "/vuonghuynh-poc/dev/AppMemoryHardLimit" --value "640" --type "String" --overwrite --region ap-southeast-1
# aws ssm put-parameter --name "/vuonghuynh-poc/dev/AppMemorySoftLimit" --value "256" --type "String" --overwrite --region ap-southeast-1

aws ssm put-parameter --name "/vuonghuynh-poc/dev/ContainerStartTimeout" --value "120" --type "String" --overwrite --region ap-southeast-1
aws ssm put-parameter --name "/vuonghuynh-poc/dev/ContainerStopTimeout" --value "5" --type "String" --overwrite --region ap-southeast-1
