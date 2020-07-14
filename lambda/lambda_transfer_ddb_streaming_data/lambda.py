import os
import json
import boto3

firehose = boto3.client('firehose')


def lambda_handler(event, context):
    for record in event['Records']:
        ddb = record['dynamodb']   
        data = json.dumps(ddb['NewImage'])
        print(data)
        try:
            response = firehose.put_record(
                DeliveryStreamName=os.environ['DeliveryStreamName'],
                Record={
                    'Data': data
                })
        
            print(response)
        except Exception as e:
            print(e)