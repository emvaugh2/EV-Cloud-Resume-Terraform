resource "azurerm_cosmosdb_account" "crc_cosmos" {
  name                = "ev-crc-cosmos"
  location            = azurerm_resource_group.crc_rg.location
  resource_group_name = azurerm_resource_group.crc_rg.name

  offer_type = "Standard"
  kind       = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = "Central US"
    failover_priority = 0
  }

  automatic_failover_enabled = true

}

resource "azurerm_storage_account" "function_storage" {
  name                = "evcrcfunctionstorage"
  location            = azurerm_resource_group.crc_rg.location
  resource_group_name = azurerm_resource_group.crc_rg.name

  account_tier             = "Standard"
  account_replication_type = "LRS"

  account_kind = "StorageV2"

  min_tls_version = "TLS1_2"

  https_traffic_only_enabled = true

  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true

}

resource "azurerm_application_insights" "crc_appinsights" {
  name                = "ev-crc-function"
  location            = azurerm_resource_group.crc_rg.location
  resource_group_name = azurerm_resource_group.crc_rg.name

  application_type = "web"

}

resource "azurerm_cosmosdb_sql_database" "resume_db" {
  name                = "ResumeDB"
  resource_group_name = azurerm_resource_group.crc_rg.name
  account_name        = azurerm_cosmosdb_account.crc_cosmos.name
}

resource "azurerm_cosmosdb_sql_container" "visitor_count" {
  name                  = "VisitorCount"
  resource_group_name   = azurerm_resource_group.crc_rg.name
  account_name          = azurerm_cosmosdb_account.crc_cosmos.name
  database_name         = azurerm_cosmosdb_sql_database.resume_db.name
  partition_key_paths   = ["/id"]
  partition_key_version = 2
}

resource "azurerm_function_app_flex_consumption" "crc_function" {
  name                = "ev-crc-function"
  resource_group_name = azurerm_resource_group.crc_rg.name
  location            = azurerm_resource_group.crc_rg.location
  service_plan_id = azurerm_service_plan.crc_function_plan.id
  runtime_name    = "python"
  runtime_version = "3.14"
  storage_container_type      = "blobContainer"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_container_endpoint = "https://evcrcfunctionstorage.blob.core.windows.net/app-package-ev-crc-function-16eb6c4"
  site_config {
  }
}



resource "azurerm_service_plan" "crc_function_plan" {
  name                = "ASP-rgevcrcprod-b961"
  location            = azurerm_resource_group.crc_rg.location
  resource_group_name = azurerm_resource_group.crc_rg.name
  os_type  = "Linux"
  sku_name = "FC1"
}