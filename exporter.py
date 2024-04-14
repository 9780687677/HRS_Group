import redis
import boto3
import json
import csv

# Connect to ElastiCache
redis_client = redis.StrictRedis(host='your-redis-endpoint', port=6379, decode_responses=True)

# Fetch data from cache
data = redis_client.get('your-key-name')

# Export data to S3
s3_client = boto3.client('s3')
bucket_name = 'your-s3-bucket-name'
key = 'exported_data.json'

# Convert data to JSON and upload to S3
s3_client.put_object(Body=json.dumps(data), Bucket=bucket_name, Key=key)
print(f"Data exported to S3 bucket: s3://{bucket_name}/{key}")
