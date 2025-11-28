import boto3
from botocore.exceptions import ClientError

# 1) List all files in an S3 bucket
def list_s3_objects(bucket_name):
    s3 = boto3.client("s3")
    print(f"Objects in bucket: {bucket_name}")
    try:
        response = s3.list_objects_v2(Bucket=bucket_name)
        contents = response.get("Contents", [])
        if not contents:
            print("  (No objects found)")
        for obj in contents:
            print(f"  - {obj['Key']} (Size: {obj['Size']})")
    except ClientError as e:
        print(f"Error listing objects: {e}")

# 2) Create a DynamoDB table
def create_dynamodb_table(table_name):
    dynamodb = boto3.client("dynamodb")
    try:
        response = dynamodb.create_table(
            TableName=table_name,
            AttributeDefinitions=[
                {"AttributeName": "id", "AttributeType": "S"}
            ],
            KeySchema=[
                {"AttributeName": "id", "KeyType": "HASH"}
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        print(f"Creating table {table_name}...")
        waiter = dynamodb.get_waiter("table_exists")
        waiter.wait(TableName=table_name)
        print(f"Table {table_name} created.")
    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceInUseException":
            print(f"Table {table_name} already exists.")
        else:
            print(f"Error creating table: {e}")

# 3) Insert an item into the DynamoDB table
def put_item(table_name, item_id, data):
    dynamodb = boto3.client("dynamodb")
    try:
        dynamodb.put_item(
            TableName=table_name,
            Item={
                "id": {"S": item_id},
                "data": {"S": data}
            }
        )
        print(f"Inserted item with id={item_id} into {table_name}.")
    except ClientError as e:
        print(f"Error putting item: {e}")

if __name__ == "__main__":
    BUCKET_NAME = "jjhw3bucket"       # your S3 bucket
    TABLE_NAME = "Homework3Table"     # DynamoDB table name

    list_s3_objects(BUCKET_NAME)
    create_dynamodb_table(TABLE_NAME)
    put_item(TABLE_NAME, "1", "Sample homework item")
