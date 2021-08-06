#Manage Azure KeyVault Secrets from CI
import os, cmd, argparse
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

parser = argparse.ArgumentParser()
parser.add_argument('--add', help='Add a secret to the vault, [Name] [Key]')
parser.add_subparsers("KeyName")
parser.add_subparsers("KeyValue")
args = parser.parse_args()
print(args)

keyVaultName = os.environ["KEY_VAULT_NAME"]
keyVaultURI = f"https://{keyVaultName}.vault.azure.net"
credential = DefaultAzureCredential()
client = SecretClient(vault_url=keyVaultURI, credential=credential)

print("Welcome!")
print(f"Personal keyvault name read as: {keyVaultName}")


