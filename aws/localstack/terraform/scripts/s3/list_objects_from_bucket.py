import boto3

s3 = boto3.client('s3',
                  aws_access_key_id='test',
                  aws_secret_access_key='test',
                  endpoint_url='http://localhost:4566')

bucket_name = 'local-bucket'

response = s3.list_objects(Bucket=bucket_name)

for obj in response.get('Contents', []):
    print(obj['Key'])
