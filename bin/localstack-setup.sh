#!/bin/sh
echo "Initializing localstack services"

echo "########### Creating level -1 bucket ###########"
awslocal s3api create-bucket --bucket ukceh-fdri-timeseries-level-m1 --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2


echo "########### Add objects to level -1 bucket for end to end test ###########"
awslocal s3api put-object --bucket ukceh-fdri-timeseries-level-m1 --key test/BUNNY/PRECIP_1MIN_2024_LOOPED/1718984022900-ca40c62a05cf740a1529eb5endtoend1 --body /var/lib/localstack/ingestion/BUNNY/PRECIP_1MIN_2024_LOOPED/1718984022900-ca40c62a05cf740a1529eb5endtoend1
awslocal s3api put-object --bucket ukceh-fdri-timeseries-level-m1 --key test/BUNNY/PRECIP_1MIN_2024_LOOPED/1718983962899-6e1749d9c4882ac7e1bae1bendtoend2 --body /var/lib/localstack/ingestion/BUNNY/PRECIP_1MIN_2024_LOOPED/1718983962899-6e1749d9c4882ac7e1bae1bendtoend2


echo "########### Creating level-0 bucket ###########"
awslocal s3api create-bucket --bucket ukceh-fdri-timeseries-level-0 --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2


echo "########### Load parquet data into level-0 bucket #########"
BUCKET="ukceh-fdri-staging-timeseries-level-0"
LOCAL_DIR="/var/lib/localstack/timeseries_processor"

# Loop through all parquet files in the directory and its subdirectories
find "$LOCAL_DIR" -type f -name "*.parquet" | while read -r FILEPATH; do
    # Extract the relative path after the base directory
    RELATIVE_PATH="${FILEPATH#$LOCAL_DIR/}"

    # Construct the S3 key
    S3_KEY="$RELATIVE_PATH"

    # Upload the file to the S3 bucket
    awslocal s3api put-object --bucket "$BUCKET" --key "$S3_KEY" --body "$FILEPATH"
done


echo "########### Creating qc bucket ###########"
awslocal s3api create-bucket --bucket ukceh-fdri-staging-timeseries-qc --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2


echo "########### Creating dynamodb table ###########"
awslocal dynamodb create-table \
    --table-name FDRI_Message_Status \
    --attribute-definitions AttributeName=MessageHash,AttributeType=S \
    --key-schema AttributeName=MessageHash,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=20,WriteCapacityUnits=20 \
    --region eu-west-2


echo "########### Creating sqs queue ###########"
awslocal sqs create-queue --queue-name ukceh_timeseries_level_m1_object_creation --region eu-west-2


echo "########### Creating bucket event notification ###########"
aws --endpoint-url=http://localstack:4566 s3api put-bucket-notification-configuration\
    --bucket ukceh-fdri-timeseries-level-m1\
    --notification-configuration '{
                                    "QueueConfigurations":[
                                        {
                                            "QueueArn": "arn:aws:sqs:eu-west-2:000000000000:ukceh_timeseries_level_m1_object_creation",
                                            "Events": ["s3:ObjectCreated:*"]
                                        }
                                        ]
                                    }'
