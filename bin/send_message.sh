#!/bin/bash
if [ $1 = "PRECIP_1MIN_2024_LOOPED" ]; then
    type="BUNNY/PRECIP_1MIN_2024_LOOPED"
    echo "loading PRECIP_1MIN_2024_LOOPED data"
elif [ $1 = "SOILMET_30MIN_2024_LOOPED" ]; then
    type="FINCH/SOILMET_30MIN_2024_LOOPED"
    echo "loading SOILMET_30MIN_2024_LOOPED data"
elif [ $1 = "bad_schemas" ]; then
    type="bad_schemas"
    echo "loading bad_schemas data"
else
    echo "first argument must be either 'PRECIP_1MIN_2024_LOOPED', 'SOILMET_30MIN_2024_LOOPED' or 'bad_schemas'"
    exit 1
fi

if [ -z "$2" ]; then
    if [ $type = "BUNNY/PRECIP_1MIN_2024_LOOPED" ]; then
        echo "loading batch of messages by default"
        BUCKET="ukceh-fdri-timeseries-level-m1"
        LOCAL_DIR="/var/lib/localstack/cosmos-data/$type"

        find "$LOCAL_DIR" -type f -not -name "*endtoend*" | while read -r FILEPATH; do

            FILE="$(basename "${FILEPATH}")"
            
            # Construct the S3 key
            S3_KEY="test/${type}/${FILE}"

            # Upload the file to the S3 bucket
            awslocal s3api put-object --bucket "$BUCKET" --key "$S3_KEY" --body "$FILEPATH"
        done

    elif [ $type = "FINCH/SOILMET_30MIN_2024_LOOPED" ]; then
        echo "loading batch of messages by default"
        BUCKET="ukceh-fdri-timeseries-level-m1"
        LOCAL_DIR="/var/lib/localstack/cosmos-data/$type"

        find "$LOCAL_DIR" -type f -name "*" | while read -r FILEPATH; do

            FILE="$(basename "${FILEPATH}")"
            
            # Construct the S3 key
            S3_KEY="test/${type}/${FILE}"

            # Upload the file to the S3 bucket
            awslocal s3api put-object --bucket "$BUCKET" --key "$S3_KEY" --body "$FILEPATH"
        done
    
    elif [ $type = "bad_schemas" ]; then
        echo "loading /var/lib/localstack//cosmos-data/$type/1718983902896-5028ceb1ca1211bb5ab47f3a4abadkey by default"
        awslocal s3api put-object --bucket ukceh-fdri-timeseries-level-m1 --key test/bad_schemas/1718983902896-5028ceb1ca1211bb5ab47f3a4abadkey --body /var/lib/localstack/cosmos-data/$type/1718983902896-5028ceb1ca1211bb5ab47f3a4abadkey
    fi
else
    for file in "${@:2}"
    do
        echo "loading /var/lib/localstack/cosmos-data/$type/$file"
        awslocal s3api put-object --bucket ukceh-fdri-timeseries-level-m1 --key test/$type/$file --body /var/lib/localstack/cosmos-data/$type/$file
    done
fi

