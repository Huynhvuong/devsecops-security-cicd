#!/bin/bash
set -eux

env_variables=(
    "AppTaskCPU"
    "AppTaskMemory"
    "ContainerStartTimeout"
    "ContainerStopTimeout"
    "AppCpuHardLimit"
    "AppMemoryHardLimit"
    "AppMemorySoftLimit"
    "SecureContainerPort"
)
## Retrieve parameters
for var_name in "${env_variables[@]}"; do
    value=$(aws ssm get-parameter --name "/$PROJECT_NAME/$TARGET_ENV/$var_name" --query "Parameter.Value" --region $AWS_REGION --output text)
    export "$var_name=$value"
done

./create-app-taskDefinition.sh
cat ${PROJECT_NAME}-$MICROSERVICE_NAME-taskDefinition.json

BE_TASKDEFINITION=$(aws ecs register-task-definition --region $AWS_REGION \
    --cli-input-json file://${PROJECT_NAME}-$MICROSERVICE_NAME-taskDefinition.json \
    --query 'taskDefinition.taskDefinitionArn' --output text)

echo "Deploy ${MICROSERVICE_NAME}-${TARGET_ENV} service"

ecs deploy ${PROJECT_NAME}-${TARGET_ENV} ${PROJECT_NAME}-${TARGET_ENV}-${MICROSERVICE_NAME}-service --task $BE_TASKDEFINITION --timeout 900
