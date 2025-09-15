import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info('## ENVIRONMENT VARIABLES')
    logger.info(os.environ)

    logger.info('## EVENT')
    logger.info(event)

    # Access S3 bucket name from event
    bucketname = event['Records'][0]['s3']['bucket']['name']
    print(f'There is change in S3 bucket {bucketname}')

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda - Learnbay!')
    }