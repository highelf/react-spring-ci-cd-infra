#!/bin/bash

set -e  # Stop script on any error

# Log in to Azure
az login --output none

# Set the subscription ID
export AZURE_SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Create a resource group
RESOURCE_GROUP_NAME="myResourceGroup"
LOCATION="eastus"
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --output none

# Create a storage account (for Terraform state)
STORAGE_ACCOUNT_NAME="mytfstateaccount$RANDOM"
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --location $LOCATION --sku Standard_LRS --encryption-services blob --output none

# Get the storage account key
export ARM_ACCESS_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' --output tsv)

# Create a storage container for the Terraform state file
az storage container create --name tfstate --account-name $STORAGE_ACCOUNT_NAME --output none

# Create a Service Principal with Contributor role
SP_JSON=$(az ad sp create-for-rbac --name "myServicePrincipal" --role Contributor --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID" --query '{client_id: appId, client_secret: password, tenant_id: tenant}' --output json)

export AZURE_CLIENT_ID=$(echo $SP_JSON | jq -r .client_id)
export AZURE_CLIENT_SECRET=$(echo $SP_JSON | jq -r .client_secret)
export AZURE_TENANT_ID=$(echo $SP_JSON | jq -r .tenant_id)

# Set all necessary permission for service principal
az role assignment create --assignee $AZURE_CLIENT_ID --role "User Access Administrator" --scope /subscriptions/$AZURE_SUBSCRIPTION_ID
az role assignment create --assignee $AZURE_CLIENT_ID --role "Key Vault Secrets Officer" --scope /subscriptions/$AZURE_SUBSCRIPTION_ID

# Print Terraform environment variables
echo "Export the following variables to use Terraform:"
echo "export ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
echo "export ARM_CLIENT_ID=$AZURE_CLIENT_ID"
echo "export ARM_CLIENT_SECRET=$AZURE_CLIENT_SECRET"
echo "export ARM_TENANT_ID=$AZURE_TENANT_ID"
echo "export ARM_ACCESS_KEY=$ARM_ACCESS_KEY"
echo "export STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME"

# Done
echo "Service Principal created successfully and is ready for Terraform!"
