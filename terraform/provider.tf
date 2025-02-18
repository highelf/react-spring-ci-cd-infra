terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"  # Use version 4.x of the AzureRM provider
    }
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}