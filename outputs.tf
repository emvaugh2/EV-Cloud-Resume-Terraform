
# Returns output for resource group (RG)
output "resource_group_name" {
  description = "CRC resource group name"
  value       = azurerm_resource_group.crc_rg.name
}

# Returns output for RG's ID
output "resource_group_id" {
  description = "CRC resource group Azure resource ID"
  value       = azurerm_resource_group.crc_rg.id
}