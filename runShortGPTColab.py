from gui.gui_gradio import ShortGptUI
from azure_key_vault import load_secrets_from_key_vault

# Load secrets from Azure Key Vault if enabled
load_secrets_from_key_vault()

app = ShortGptUI(colab=True)
app.launch()
