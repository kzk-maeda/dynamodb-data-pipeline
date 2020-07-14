region="ap-northeast-1"
profile="kakehashi-sandbox-terraform"
env="sandbox"
s3_bucket_name="s3bucket-sandbox-kamikaze2"

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
