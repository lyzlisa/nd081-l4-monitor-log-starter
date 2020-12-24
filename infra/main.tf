# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "4d8a8807-092f-4f2a-9190-e37f3db3dabf"
}

resource "azurerm_resource_group" "rg" {
  name     = "hello-world-rg"
  location = "eastus2"
}

resource "random_string" "appsvcplan" {
  length  = 24
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = random_string.appsvcplan.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "random_string" "appsvc" {
  length  = 24
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_app_service" "example" {
  name                = random_string.appsvc.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  app_settings = {
    "SOME_KEY" = "some-value"
  }
}
