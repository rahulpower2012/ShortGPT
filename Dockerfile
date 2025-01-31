# Use an official Python runtime as the parent image
FROM python:3.10-slim-bullseye
RUN apt-get update && apt-get install -y ffmpeg

# Set the working directory in the container to /app
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Add Azure Key Vault requirements
RUN echo "azure-identity==1.13.0" >> requirements.txt
RUN echo "azure-keyvault-secrets==4.7.0" >> requirements.txt

# Install dependencies
RUN pip install -r requirements.txt

# Copy the local package directory content into the container at /app
COPY . /app

EXPOSE 31415

# Add Azure Key Vault integration script
COPY azure_key_vault.py .

# Print environment variables (for debugging purposes, you can remove this line if not needed)
RUN ["printenv"]

# Set environment variables for Azure Key Vault integration
ENV AZURE_KEY_VAULT_ENABLED=true

# Run Python script when the container launches
CMD ["python", "-u", "./runShortGPTColab.py"]
