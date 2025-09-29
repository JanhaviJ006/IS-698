import boto3

s3 = boto3.client("s3", region_name="us-east-1")
bucket_name = "janhavis3bucket2"
file_name   = "jjfile.txt"

s3.delete_object(Bucket=bucket_name, Key=file_name)
print(f"File {file_name} deleted successfully from s3://{bucket_name}/{file_name}!")
