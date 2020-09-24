##############################
## Azure App Service - Main ##
##############################

# Create a Resource Group
resource "azurerm_resource_group" "appservice-rg" {
  name     = "jti-${var.region}-${var.environment}-${var.app_name}-app-service-rg"
  location = var.location

  tags = {
    description = var.description
    environment = var.environment
    owner       = var.owner  
  }
}

# Create the App Service Plan
resource "azurerm_app_service_plan" "service-plan" {
  name                = "jti-${var.region}-${var.environment}-${var.app_name}-service-plan"
  location            = azurerm_resource_group.appservice-rg.location
  resource_group_name = azurerm_resource_group.appservice-rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Free"
    size = "F1"
  }

  tags = {
    description = var.description
    environment = var.environment
    owner       = var.owner  
  }
}

# Create the App Service
resource "azurerm_app_service" "app-service" {
  name                = "jti-${var.region}-${var.environment}-${var.app_name}-app-service"
  location            = azurerm_resource_group.appservice-rg.location
  resource_group_name = azurerm_resource_group.appservice-rg.name
  app_service_plan_id = azurerm_app_service_plan.service-plan.id

  site_config {
    linux_fx_version = "DOTNETCORE|3.1"
    use_32_bit_worker_process = true
  }

  tags = {
    description = var.description
    environment = var.environment
    owner       = var.owner  
  }
}

#create sql server
resource "azurerm_sql_server" "sql-server" {
  name                         = "jti-${var.region}-${var.environment}-${var.app_name}-sql-server"
  resource_group_name          = azurerm_resource_group.appservice-rg.name
  location                     = azurerm_resource_group.appservice-rg.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd2"

  tags = {
    description = var.description
    environment = var.environment
    owner       = var.owner  
  }
}

#create storage account
resource "azurerm_storage_account" "storage-account" {
  name                     = "jti${var.app_name}storage"
  resource_group_name      = azurerm_resource_group.appservice-rg.name
  location                 = azurerm_resource_group.appservice-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#create sql database
resource "azurerm_sql_database" "sql-database" {
  name                = "jti-${var.region}-${var.environment}-${var.app_name}-sql-database"
  resource_group_name = azurerm_resource_group.appservice-rg.name
  location            = azurerm_resource_group.appservice-rg.location
  server_name         = azurerm_sql_server.sql-server.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.storage-account.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.storage-account.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }



  tags = {
    environment = "production"
  }
}