"""
sample message

{
    'invocationId': '10a63724-4265-4d51-b065-5f7a3e3b010c',
    'deliveryStreamArn': 'arn:aws:firehose:ap-northeast-1:158847477727:deliverystream/tst-firehose-stream',
    'region': 'ap-northeast-1',
    'records': [
        {
            'recordId': '49607532964074259091500051135174401270845081472622133250000000',
            'approximateArrivalTimestamp': 1590996202126,
            'data': 'eyJuYW1lX2thbmFfc2VhcmNoIjogeyJTIjogInh4eCJ9LCAicGhhcm1hY3lfaWQiOiB7IlMiOiAieHh4In0sICJiaXJ0aGRheV9zZWFyY2giOiB7IlMiOiAieHh4LWFhYS1hYWEifSwgImlkIjogeyJTIjogIjIwMjAtMDYtMDEtMDIifX0='
            
        }
    ]
}

実際にFirehoseが受信したMessageはdata内にbase64でencodeされて格納されている

Lambdaが返すべき値は下記

{
  "records": [
    {
      "recordId": "49607016322531838770965472870713485392692964656771235842000000",
      "result": "Ok",
      "data": "eyJhIjogImM3NjNlM2I5LWI1NDQtNDg4NS04YWM1LWQ3ZDg4MjJjNGNmYyIsICJiIjogImQ1NjNiYWU0LTYwZTItNDhiOC1hZTQ0LTdkYjU2ZTZlNTZkNSIsICJjIjogIjljZjNkYmE3LTY2NTEtNGE2MC1iOGJhLThkNmFhMGYwMjNkMiJ9"
    },
    {
      "recordId": "49607016322531838770965472870714694318512579354665418754000000",
      "result": "Ok",
      "data": "eyJhIjogIjUxNDJhMGUwLTdiMWYtNGMxNS1iZjBiLThhMjU2ZmQzZjkyYyIsICJiIjogImNkZTVmNWRmLWUzMGMtNGE2Yi1iNjJjLWZiNmY3Zjk1NTYzNSIsICJjIjogIjljN2YyMWRlLWU2MWItNGJhZi05YjQ0LTg2MmE0YmVhZTVlMiJ9"
    }
  ]
}

考慮すべきポイント
- レコード数が500を越える時、分割する必要がある
- Totalレコードサイズが6MBを越える時、Firehoseに戻す必要がある

"""

import json
import boto3
import base64
from datetime import datetime

PAYLOAD_MAX_SIZE = 6000000
# PAYLOAD_MAX_SIZE = 60000
MAX_RECORD_COUNT = 500
# MAX_RECORD_COUNT = 50

def transform(data):
    """
    データ変換関数
    """
    data['NewColumn'] = 'New Value'
    # Change Scheme
    id = data.get('id').get('S')
    patient_id = data.get('patient_id').get('S')
    pharmacy_id = data.get('pharmacy_id').get('S')
    created = data.get('created').get('S')
    created = datetime.strptime(created, '%Y-%m-%dT%H:%M:%S').strftime('%Y-%m-%d %H:%M:%S')
    updated_at = data.get('updated_at').get('S')
    updated_at = datetime.strptime(updated_at, '%Y-%m-%dT%H:%M:%S').strftime('%Y-%m-%d %H:%M:%S')
    
    return_data = f'{id},{patient_id},{pharmacy_id},{created},{updated_at}'
    print(return_data)

    return return_data


def proceed_records(records):
    """
    transform each data and yield each record
    """
    for record in records:
        record_id = record.get('recordId')
        data = json.loads(base64.b64decode(record.get('data')))
        # print("Raw Data : " + str(data))
        try:
            transformed_data = transform(data)
            result = 'Ok'
        except Exception as e:
            print(e)
            transformed_data = data
            result = 'ProcessingFailed'
        print("New Data : " + transformed_data)
        
        # proceeded_data = json.dumps(transformed_data) + '\n'
        proceeded_data = transformed_data + '\n'
        
        return_record = {
            "recordId": record_id,
            "result": result,
            "data": base64.b64encode(proceeded_data.encode('utf-8'))
        }

        yield return_record


def put_records_to_firehose(streamName, records, client):
    print('Trying to return record to firehose')
    print(f'Item count: {len(records)}')
    print(f'Record: {str(records)}')
    try:
        response = client.put_record_batch(DeliveryStreamName=streamName, Records=records)
    except Exception as e:
        # failedRecords = records
        errMsg = str(e)
        print(errMsg)
    

def lambda_handler(event, context):
    invocation_id = event.get('invocationId')
    event_records = event.get('records')
    # Transform Data
    records = list(proceed_records(event_records))
    
    # Check Data
    projected_size = 0 # Responseサイズが6MBを超えない様制御
    data_by_record_id = {rec['recordId']: _create_reingestion_record(rec) for rec in event['records']}
    total_records_to_be_reingested = 0
    records_to_reingest = []
    put_record_batches = []
    for idx, rec in enumerate(records):
        if rec['result'] != 'Ok':
            continue
        projected_size += len(rec['data']) + len(rec['recordId'])
        if projected_size > PAYLOAD_MAX_SIZE:
            """
            Lambda 同期呼び出しモードには、リクエストとレスポンスの両方について、
            ペイロードサイズに 6 MB の制限があります。
            https://docs.aws.amazon.com/ja_jp/firehose/latest/dev/data-transformation.html
            """
            print(f"Payload size has been exceeded over {PAYLOAD_MAX_SIZE/1000/1000}MB")
            total_records_to_be_reingested += 1
            records_to_reingest.append(
                _get_reingestion_record(data_by_record_id[rec['recordId']])
            )
            records[idx]['result'] = 'Dropped'
            del(records[idx]['data'])
        
        if len(records_to_reingest) == MAX_RECORD_COUNT:
            """
            Each PutRecordBatch request supports up to 500 records.
            https://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecordBatch.html
            """
            print(f'Records count has been exceeded over {MAX_RECORD_COUNT}')
            put_record_batches.append(records_to_reingest)
            records_to_reingest = []
    
    if len(records_to_reingest) > 0:
        # add the last batch
        put_record_batches.append(records_to_reingest)
            
    # iterate and call putRecordBatch for each group
    records_reingested_already = 0
    stream_arn = event['deliveryStreamArn']
    region = stream_arn.split(':')[3]
    stream_name = stream_arn.split('/')[1]
    if len(put_record_batches) > 0:
        client = boto3.client('firehose', region_name=region)
        for record_batch in put_record_batches:
            put_records_to_firehose(stream_name, record_batch, client)
            records_reingested_already += len(record_batch)
            print(f'Reingested {records_reingested_already}/{total_records_to_be_reingested} records out of {len(event["records"])}')
    else:
        print('No records to be reingested')
        
    
    # Return records to Firehose
    return_records = {
        'records': records
    }
    print(str(return_records))
    return return_records


# Transform method for temporary data
def _create_reingestion_record(original_record):
    return {'data': base64.b64decode(original_record['data'])}

def _get_reingestion_record(re_ingestion_record):
    return {'Data': re_ingestion_record['data']}