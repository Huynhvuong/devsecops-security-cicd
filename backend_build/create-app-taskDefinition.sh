#!/bin/bash

cat <<EOF >${PROJECT_NAME}-app-taskDefinition.json
{
    "containerDefinitions": [
        {
            "name": "${PROJECT_NAME}-$TARGET_ENV-app-container",
            "image": "$ImageURI",
            "cpu": $AppCpuHardLimit,
            "memory": $AppMemoryHardLimit,
            "memoryReservation": $AppMemorySoftLimit,
            "portMappings": [
                {
                    "containerPort": 3000,
                    "hostPort": 3000,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "AWSSMREGION",
                    "value": "$AWS_REGION"
                },
                {
                    "name": "STAGE",
                    "value": "$TARGET_ENV"
                },
                {
                    "name": "PROJECT_NAME",
                    "value": "$PROJECT_NAME"
                }
            ],
            "linuxParameters": {
                "initProcessEnabled": true
            },
            "secrets": [
                {
                    "name": "APP_URL",
                    "valueFrom": "/$PROJECT_NAME/$TARGET_ENV/APP_URL"
                }
            ],
            "startTimeout": $ContainerStartTimeout,
            "stopTimeout": $ContainerStopTimeout,
            "dockerLabels": {
                "com.vh.ad.check_names": "[${PROJECT_NAME}-$TARGET_ENV-app-container]",
                "com.vh.ad.init_configs": "[{}]",
                "com.vh.ad.instances": "[{\"host\": \"%%host%%\", \"port\": 3000}]",
                "com.vh.tags.env": "$TARGET_ENV",
                "com.vh.tags.service": "${PROJECT_NAME}-$TARGET_ENV-app",
                "com.vh.tags.version": "$ImageTAG"
            },
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/${PROJECT_NAME}-$TARGET_ENV-app",
                    "mode": "non-blocking",
                    "awslogs-create-group": "true",
                    "max-buffer-size": "25m",
                    "awslogs-region": "$AWS_REGION",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            },
            "healthCheck": {
                "command": [
                    "CMD-SHELL",
                    "echo 'Healthy' || exit 1"
                ],
                "interval": 30,
                "timeout": 5,
                "retries": 3,
                "startPeriod": 120
            }
        }
    ],
    "family": "${PROJECT_NAME}-$TARGET_ENV-app-taskdefinition",
    "taskRoleArn": "arn:aws:iam::$ACCOUNT:role/${PROJECT_NAME}-$TARGET_ENV-ecs-task-role",
    "executionRoleArn": "arn:aws:iam::$ACCOUNT:role/${PROJECT_NAME}-$TARGET_ENV-ecs-execution-role",
    "networkMode": "awsvpc",
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "$AppTaskCPU",
    "memory": "$AppTaskMemory"
}
EOF
