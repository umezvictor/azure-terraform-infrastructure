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
  #resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}

}

resource "azurerm_resource_group" "dev-rg" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_storage_account" "dev-sa" {
  name                     = var.storage_account
  resource_group_name      = azurerm_resource_group.dev-rg.name
  location                 = azurerm_resource_group.dev-rg.location
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

# resource "azurerm_service_plan" "example" {
#   name                = "example-app-service-plan"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   os_type             = "Linux"
#   sku_name            = "B1"
# }

# resource "azurerm_linux_function_app" "example" {
#   name                = "victorblaze-function-app"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location

#   storage_account_name       = azurerm_storage_account.example.name
#   storage_account_access_key = azurerm_storage_account.example.primary_access_key
#   service_plan_id            = azurerm_service_plan.example.id

#   site_config {
#     #specify node version, else it takes an older version
#     application_stack {
#       #eg dotnet, java, node version
#       node_version = 18
#     }
#   }
# }

# ensure you have local.settings.json file to your app code
# publish your settings - func azure functionapp publish <YOUR_FUNCTION_APP_NAME> --publish-settings-only
# publish your app - func azure functionapp publish <YOUR_FUNCTION_APP_NAME>