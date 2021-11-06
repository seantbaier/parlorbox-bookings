

# Upload to S3
aws s3 cp ./function.zip s3://development-post-confirmation-trigger/function.zip

# Update Lambda
aws lambda update-function-code --function-name development-post-confirmation-trigger --s3-bucket development-post-confirmation-trigger --s3-key function.zip
