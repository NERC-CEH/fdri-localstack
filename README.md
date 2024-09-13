# fdri-localstack

Configuration for localstack container used accross the FDRI project. Image is stored on ECR and pulled into FDRI apps. Used for running the apps locally and E2E testing.

Files required for testing are stored in `test_data` and mounted to the container.

`bin/localstack-setup.sh` is run on initialisation and sets up the mock AWS resources. Other shell scripts are also mounted providiing useful functionality for testing:

`send_message.sh`: puts data into the level-1 bucket to send a message to the queue.\
`clear_dynamodb.sh`: clears any entries in the dynamodb table.\
`staging_variables.sh`: exports specified variables.\
