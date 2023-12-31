terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
 name     = "rg-sc-prod-demo-new-fdb-boon"
 location = "eastus"
}
resource "azurerm_virtual_network" "vnet" {
 name                = "vnet-16.0.0.0_24-private"
 location            = azurerm_resource_group.rg.location
 resource_group_name = azurerm_resource_group.rg.name
 address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "subnet_storage" {
 name                 = "subnet-10.0.0.0_24-Private-01"
 resource_group_name  = azurerm_resource_group.rg.name
 virtual_network_name = azurerm_virtual_network.vnet.name
 address_prefixes     = ["10.0.0.0/24"]
 service_endpoints    = ["Microsoft.Storage"]
}
resource "azurerm_storage_account" "adls_storage_account" {
  name                = "scstoragenonprodfineend"
  resource_group_name = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["136.226.0.0/16","165.225.0.0/16","167.103.0.0/16"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet_storage.id]
  }

  tags = {
    environment = "NonProd",
    product = "Storage Conditions"
  }
}
