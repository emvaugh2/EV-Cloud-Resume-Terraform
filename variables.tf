
# Creates the location variable
variable "loc" {
  description = "Azure region for CRC resources"
  type        = string
  default     = "Central US"
}

# Creates the resource group (RG) variable
variable "rg_name" {
  description = "Resource Group for the Cloud Resume Challenge"
  type        = string
  default     = "rg-ev-crc-prod"
}