import logging
import boto3
import sys
import os
import urllib.parse

sys.path.append("./package")
import pymysql

# rds settings
db_name = os.environ['DB_NAME']
db_user = os.environ['DB_USER']
db_password = os.environ['DB_PASSWORD']
aurora_endpoint = os.environ['AURORA_ENDPOINT']

table_name = os.environ['TABLE_NAME']
table_schema = os.environ['TABLE_SCHEMA']

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    print(event)
    
    s3_client = boto3.client('s3')
    try:
        conn = pymysql.connect(aurora_endpoint, user=db_user, passwd=db_password, db=db_name, connect_timeout=5)
    except:
        logger.error("ERROR: Unexpected error: Could not connect to Aurora instance.")
        sys.exit()

    logger.info("SUCCESS: Connection to RDS Aurora instance succeeded")

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        s3location_encorded = 's3://' + bucket + '/' + key
        s3location = urllib.parse.unquote(s3location_encorded)
        logger.info(s3location)
    
        # sql = "LOAD DATA FROM S3 '" + s3location + "' INTO TABLE kamikaze2.prescription FIELDS TERMINATED BY ',' " \
        #       "LINES TERMINATED BY '\\n' (id, patient_id, pharmacy_id, created, updated_at);"

        sql = f"LOAD DATA FROM S3 '{s3location}' INTO TABLE {db_name}.{table_name} " \
              f"FIELDS TERMINATED BY ',' " \
              f"LINES TERMINATED BY '\\n' ({table_schema});"
               
    
        logger.info(sql)
    
        with conn.cursor() as cur:
            cur.execute(sql)
            conn.commit()
            logger.info('Data loaded from S3 into Aurora')