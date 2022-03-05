ENV=dev
APP_NAME=proper-booking-service
FUNCTION_NAME=${ENV}-${APP_NAME}

IMAGE_TAG=${APP_NAME}
AWS_ACCOUNT_ID=616285773385
AWS_DEFAULT_REGION=us-east-1

# Build Docker Image
docker build -f ./Dockerfile -t ${IMAGE_TAG} .

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
--function-name ${FUNCTION_NAME} \
--image-uri ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${APP_NAME}:latest
