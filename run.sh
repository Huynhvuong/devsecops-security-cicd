#! /bin/bash

set -e

out=$(aws secretsmanager get-secret-value --secret-id "$STAGE/env/app" --query "SecretString" --output text --region "$AWS_REGION")
[[ -n "$out" ]] && echo "$out" >.env

set -a
[ -f .env ] && source .env
set +a

function run {
  poetry run python3 main.py
}

echo Run app in $APP_ENV environment
run
