ENV=development
APP_NAME=studiosauce
FUNCTION_NAME=post-confirmation-trigger

IMAGE_TAG=${ENV}-${APP_NAME}-${FUNCTION_NAME}
AWS_ACCOUNT_ID=266568383880
AWS_DEFAULT_REGION=us-east-1

# Build Docker Image
docker build -t ${IMAGE_TAG} -f ./Dockerfile .

# Tag Docker Image
docker tag ${IMAGE_TAG}:latest \
${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_TAG}:latest

# Login to ECR
aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

# Push Docker Image
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_TAG}:latest

# Deploy new Lambda
aws lambda update-function-code \
--function-name ${ENV}-${FUNCTION_NAME} \
--image-uri ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ENV}-${APP_NAME}-${FUNCTION_NAME}:latest
