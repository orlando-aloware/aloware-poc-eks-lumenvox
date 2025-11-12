#!/bin/bash
set -e

# export AWS_PROFILE=aloware

cd ../terraform
terraform init
terraform apply -auto-approve

cd ../cluster-charts
terraform init
terraform apply -auto-approve
