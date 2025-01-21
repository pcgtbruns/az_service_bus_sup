terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
}

  subscription_id = "2c12789e-7374-4443-92a4-a6e260376a10"
}

resource "azurerm_resource_group" "some_rg_func" {
  name     = "support-case4-azfunc"
  location = "germanywestcentral"
}

resource "azurerm_resource_group" "some_rg_bus" {
  name     = "support-case4-servicebus"
  location = "germanywestcentral"
}




