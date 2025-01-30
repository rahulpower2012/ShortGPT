import os
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

def load_secrets_from_key_vault():
    """Load secrets from Azure Key Vault and set them as environment variables."""
    if not os.getenv('AZURE_KEY_VAULT_ENABLED'):
        return

    key_vault_name = os.getenv('AZURE_KEY_VAULT_NAME')
    if not key_vault_name:
        raise ValueError("AZURE_KEY_VAULT_NAME environment variable is required")

    key_vault_uri = f"https://{key_vault_name}.vault.azure.net/"
    
    # Use DefaultAzureCredential which supports managed identities
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=key_vault_uri, credential=credential)

    # Map of secret names to environment variable names
    secret_mapping = {
        'OPENAI-API-KEY': 'OPENAI_API_KEY',
        'ELEVENLABS-API-KEY': 'ELEVENLABS_API_KEY',
        'PEXELS-API-KEY': 'PEXELS_API_KEY'
    }

    # Fetch secrets and set as environment variables
    for secret_name, env_var_name in secret_mapping.items():
        try:
            secret = client.get_secret(secret_name)
            os.environ[env_var_name] = secret.value
        except Exception as e:
            print(f"Error fetching secret {secret_name}: {str(e)}")

if __name__ == '__main__':
    load_secrets_from_key_vault()
