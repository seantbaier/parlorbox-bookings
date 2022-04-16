ENV=development
APP_NAME=parlorbox-bookings-service
FUNCTION_NAME=${APP_NAME}-${ENV}

IMAGE_TAG=${FUNCTION_NAME}
AWS_ACCOUNT_ID=616285773385
AWS_DEFAULT_REGION=us-east-2

# Build Docker Image
docker build -f ./Dockerfile -t ${IMAGE_TAG} .

# Tag Docker Image
docker tag ${IMAGE_TAG}:latest \
${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_TAG}:latest

# Login to ECR
aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

# Push Docker Image
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_TAG}:latest

# Deploy new Lambda
aws lambda update-function-code \
--function-name ${FUNCTION_NAME} \
--image-uri ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${FUNCTION_NAME}:latest
