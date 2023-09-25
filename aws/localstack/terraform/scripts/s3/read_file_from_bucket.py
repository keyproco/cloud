import boto3

s3 = boto3.client('s3',
                  aws_access_key_id='test',
                  aws_secret_access_key='test',
                  endpoint_url='http://localhost:4566')

bucket_name = 'local-bucket'
object_key = 'hello.txt'

response = s3.get_object(Bucket=bucket_name, Key=object_key)
content = response['Body'].read().decode('utf-8')

print(content)