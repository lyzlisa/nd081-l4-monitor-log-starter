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
  kind                = "Linux"
  reserved            = true

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

resource "azurerm_app_service" "appsvc" {
  name                = random_string.appsvc.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  logs {
    application_logs {
      azure_blob_storage {
        level = "Warning"
        sas_url = format(
          "%s/%s%s",
          azurerm_storage_account.stacc.primary_blob_endpoint,
          azurerm_storage_container.applicationlogs.name,
          data.azurerm_storage_account_blob_container_sas.applicationlogs.sas
        )
        retention_in_days = 7
      }
    }
  }
}

resource "azurerm_storage_account" "stacc" {
  name                     = "l4monlogstoacc"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "applicationlogs" {
  name                  = "applicationlogs"
  storage_account_name  = azurerm_storage_account.stacc.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "applicationlogs" {
  connection_string = azurerm_storage_account.stacc.primary_connection_string
  container_name    = azurerm_storage_container.applicationlogs.name
  https_only        = true

  start  = "2020-12-25"
  expiry = "2021-01-21"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}
