#!/bin/bash

# Exit on error
set -e

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in to Azure
az account show &> /dev/null || {
    echo "Please login to Azure first using 'az login'"
    exit 1
}

# Configuration
echo "Please provide the following information:"
read -p "Resource Group Name: " RESOURCE_GROUP
read -p "Location (e.g., eastus): " LOCATION
read -p "Key Vault Name: " KEY_VAULT_NAME
read -p "Container Registry Name: " ACR_NAME
read -p "Container Instance Name: " CONTAINER_NAME
read -p "OpenAI API Key: " OPENAI_API_KEY
read -p "ElevenLabs API Key: " ELEVENLABS_API_KEY
read -p "Pexels API Key: " PEXELS_API_KEY

# Create resource group if it doesn't exist
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Build and push Docker image to ACR
echo "Creating Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard

# Log in to ACR
echo "Logging in to ACR..."
az acr login --name $ACR_NAME

# Build and push the image
echo "Building and pushing Docker image..."
IMAGE_NAME="$ACR_NAME.azurecr.io/shortgpt:latest"
docker build -t $IMAGE_NAME .
docker push $IMAGE_NAME

# Deploy using ARM template
echo "Deploying resources using ARM template..."
az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file azuredeploy.json \
    --parameters \
        keyVaultName=$KEY_VAULT_NAME \
        containerRegistryName=$ACR_NAME \
        containerInstanceName=$CONTAINER_NAME \
        openaiApiKey=$OPENAI_API_KEY \
        elevenlabsApiKey=$ELEVENLABS_API_KEY \
        pexelsApiKey=$PEXELS_API_KEY \
        imageName=$IMAGE_NAME

# Get the container instance IP
CONTAINER_IP=$(az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --query ipAddress.ip -o tsv)

echo "Deployment completed successfully!"
echo "Your ShortGPT instance is now running at: http://$CONTAINER_IP:31415"