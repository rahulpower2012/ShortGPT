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
read -p "Container Instance Name: " CONTAINER_NAME
read -p "OpenAI API Key: " OPENAI_API_KEY
read -p "ElevenLabs API Key: " ELEVENLABS_API_KEY
read -p "Pexels API Key: " PEXELS_API_KEY

# Create resource group if it doesn't exist
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Set the image name from GHCR
GITHUB_USERNAME="rahulpower2012"
REPO_NAME="ShortGPT"
IMAGE_NAME="ghcr.io/$GITHUB_USERNAME/$REPO_NAME:l isatest"

# Deploy using ARM template mili
echo "Deploying resources using ARM template..."
az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file azuredeploy.json \
    --parameters \
        keyVaultName=$KEY_VAULT_NAME \
        containerInstanceName=$CONTAINER_NAME \
        openaiApiKey=$OPENAI_API_KEY \
        elevenlabsApiKey=$ELEVENLABS_API_KEY \
        pexelsApiKey=$PEXELS_API_KEY \
        imageName=$IMAGE_NAME

# Get the container instance IP
CONTAINER_IP=$(az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --query ipAddress.ip -o tsv)

echo "Deployment completed successfully!"
echo "Your ShortGPT instance is now running at: http://$CONTAINER_IP:31415"
