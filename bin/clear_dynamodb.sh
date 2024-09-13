#!/bin/bash

awslocal dynamodb delete-table --table-name FDRI_Message_Status --region eu-west-2
awslocal dynamodb create-table \
    --table-name FDRI_Message_Status \
    --attribute-definitions AttributeName=MessageHash,AttributeType=S \
    --key-schema AttributeName=MessageHash,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=20,WriteCapacityUnits=20 \
    --region eu-west-2

