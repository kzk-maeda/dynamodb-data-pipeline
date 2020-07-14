region="ap-northeast-1"
profile="kakehashi-sandbox-terraform"
env="sandbox"
s3_bucket_name="s3bucket-sandbox-kamikaze2"

prescription_streaming_arn="arn:aws:dynamodb:ap-northeast-1:158847477727:table/test-prescription/stream/2020-07-14T12:41:53.964"

db_name="kamikaze2"
db_user="admin"
db_password="passw0rd"
aurora_endpoint="kamikaze2-mysql.cluster-cz44yzqeo0wl.ap-northeast-1.rds.amazonaws.com"

prescription_table="prescription"
prescription_schema="id, patient_id, pharmacy_id, created, updated_at"

subnet_ids = [
    "subnet-0837b8ea569184f72",
    "subnet-05fd2e0c7c5d8121e"
]

security_group_ids = [
    "sg-0339c1fe7e8f2b6b1",
    "sg-05ae08239f1e565cd"
]
