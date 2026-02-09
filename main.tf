# This Terraform configuration creates a Flex Consumption plan app in Azure Functions 
# with the required Storage account and Blob Storage deployment container.

# Create a random pet to generate a unique resource group name
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Create a resource group
resource "azurerm_resource_group" "dev_rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Random String for unique naming of resources
resource "random_string" "name" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  numeric = false
}

# Create a storage account
resource "azurerm_storage_account" "dev_storage_account" {
  name                     = coalesce(var.sa_name, random_string.name.result)
  resource_group_name      = azurerm_resource_group.dev_rg.name
  location                 = azurerm_resource_group.dev_rg.location
  account_tier             = var.sa_account_tier
  account_replication_type = var.sa_account_replication_type
}

# Create a storage container
resource "azurerm_storage_container" "dev_storage_container" {
  name                  = "appcontainer"
  container_access_type = "private"
  storage_account_name  = azurerm_storage_account.dev_storage_account.name
}

# Create a Log Analytics workspace for Application Insights
resource "azurerm_log_analytics_workspace" "dev_analytics" {
  name                = coalesce(var.ws_name, random_string.name.result)
  location            = azurerm_resource_group.dev_rg.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create an Application Insights instance for monitoring
resource "azurerm_application_insights" "dev_app_insights" {
  name                = coalesce(var.ai_name, random_string.name.result)
  location            = azurerm_resource_group.dev_rg.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.dev_analytics.id
}

resource "azurerm_service_plan" "dev_service_plan" {
  name                = "vicdev-service-plan"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = azurerm_resource_group.dev_rg.location
  sku_name            = "Y1"
  os_type             = "Linux"
}

resource "azurerm_linux_function_app" "weather_api" {
  name                = "vicdev-weatherapi"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = azurerm_resource_group.dev_rg.location

  storage_account_name       = azurerm_storage_account.dev_storage_account.name
  storage_account_access_key = azurerm_storage_account.dev_storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.dev_service_plan.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }
}

