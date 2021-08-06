'''Welcome! This tool will allow you to get and set Keys from your existing Azure Key Vault. \n
    Ensure you have Azure Command-Line Interface installed: https://docs.microsoft.com/en-us/cli/azure/ \n
Then run `az login` to authenticate. This will open your default browser. \n
If this is your first time using this or any CLI tool to manage keys in KeyVault \n
the following command is needed to grant access to your vault: \n
az keyvault set-policy --name <YourKeyVaultName> --upn user@domain.com --secret-permissions delete get list set \n
\n
*Note user@domain.com is your AAD User Principle Name and probably is not your email. \n
 If your UPN is unknown, try 'az ad user list' to see if you exist. \n
'''

import os, cmd, argparse
from azure.keyvault.secrets import SecretClient
from azure.identity import AzureCliCredential



parser = argparse.ArgumentParser(description=__doc__)
subparser = parser.add_subparsers(dest='command')
add = subparser.add_parser('add', help="--keyname [Name] --keyvalue [Key Value to Store]")
getkeyvalue = subparser.add_parser('get', help="--keyname [Name]")

add.add_argument('--keyname', required=True)
add.add_argument('--keyvalue', required=True)

getkeyvalue.add_argument('--keyname', required=True)
args = parser.parse_args()

keyVaultName = os.environ["KEY_VAULT_NAME"]
keyVaultURI = f"https://{keyVaultName}.vault.azure.net"
credential = AzureCliCredential()
client = SecretClient(vault_url=keyVaultURI, credential=credential)


if args.command == 'add':
    print(f"Creating a secret in {keyVaultName} called '{args.keyname}' with the value '{args.keyvalue}' ...")
    client.set_secret(args.keyname, args.keyvalue)
elif args.command == 'get':
    print(f"Retrieving your secret from {keyVaultName}.")
    stored_value = client.get_secret(args.keyname)
    print(f"The stored value for {args.keyname} is {stored_value.value}")
else:
    print("Please use --help for more command information.")






