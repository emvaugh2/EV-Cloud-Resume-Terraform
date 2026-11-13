
# Creates our resource group

resource "azurerm_resource_group" "crc_rg" {
  name     = var.rg_name
  location = var.loc

  tags = {
    Project     = "Cloud-Resume-Challenge"
    Environment = "Production"
    Owner       = "EV"
    ManagedBy   = "Terraform"
  }
}


# Creates Storage Account

resource "azurerm_storage_account" "crc_storage" {
  name                = "evcrcstorageaccount2026"
  resource_group_name = azurerm_resource_group.crc_rg.name
  location            = azurerm_resource_group.crc_rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  allow_nested_items_to_be_public = false

  tags = {
    Project     = "Cloud-Resume-Challenge"
    Environment = "Production"
    Owner       = "EV"
    ManagedBy   = "Terraform"
  }
}



# Creates Static Website

resource "azurerm_storage_account_static_website" "crc_website" {
  storage_account_id = azurerm_storage_account.crc_storage.id

  index_document = "index.html"
}


# Creates the Front Door Profile

resource "azurerm_cdn_frontdoor_profile" "crc_frontdoor" {
  name                = "afd-ev-crc-prod"
  resource_group_name = azurerm_resource_group.crc_rg.name
  sku_name            = "Standard_AzureFrontDoor"

  tags = {
    Project     = "Cloud-Resume-Challenge"
    Environment = "Production"
    Owner       = "EV"
    ManagedBy   = "Terraform"
  }

}


# Creates the AFD Endpoint

resource "azurerm_cdn_frontdoor_endpoint" "crc_afd_endpoint" {
  name                     = "ev-crc"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.crc_frontdoor.id
}


# Creates the AFD Origin Group

resource "azurerm_cdn_frontdoor_origin_group" "crc_afd_og" {
  name                     = "default-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.crc_frontdoor.id

  health_probe {
    protocol            = "Https"
    interval_in_seconds = 100
    request_type        = "HEAD"
    path                = "/"
  }

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }

}


# Creates the AFD Origin

resource "azurerm_cdn_frontdoor_origin" "crc_afd_origin" {
  name                          = "default-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.crc_afd_og.id

  enabled = true

  host_name          = azurerm_storage_account.crc_storage.primary_web_host
  origin_host_header = azurerm_storage_account.crc_storage.primary_web_host

  http_port  = 80
  https_port = 443

  certificate_name_check_enabled = true

  priority = 1
  weight   = 1000
}


