import boto3

s3 = boto3.client("s3", region_name="us-east-1")
bucket_name   = "janhavis3bucket2"
file_name     = "jjfile.txt"
download_name = "downloaded-file.txt"

s3.download_file(bucket_name, file_name, download_name)
print(f"File {file_name} downloaded successfully as {download_name}!")
