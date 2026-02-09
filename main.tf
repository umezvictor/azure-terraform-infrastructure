terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8.0"
    }
  }

  required_version = ">=1.9.0"
}


provider "azurerm" {
  features {}
}

# resource "azurerm_resource_group" "dev-rg" {
#   name     = var.resource_group
#   location = var.location
# }

resource "azurerm_storage_account" "dev-sa" {
  name                     = var.storage_account
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.env
  }
}

resource "azurerm_storage_container" "dev-storage-container" {
  name                  = var.storage_container
  container_access_type = "private"
  storage_account_name  = azurerm_storage_account.dev-sa.name
}

resource "azurerm_service_plan" "dev-sp" {
  name                = "app-service-plan"
  resource_group_name = var.resource_group
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_function_app" "dev-function-app" {
  name                = "weather-api"
  resource_group_name = var.resource_group
  location            = var.location

  storage_account_name       = azurerm_storage_account.dev-sa.name
  storage_account_access_key = azurerm_storage_account.dev-sa.primary_access_key
  service_plan_id            = azurerm_service_plan.dev-sp.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }
}

# ensure you have local.settings.json file to your app code
# publish your settings - func azure functionapp publish <YOUR_FUNCTION_APP_NAME> --publish-settings-only
# publish your app - func azure functionapp publish <YOUR_FUNCTION_APP_NAME>