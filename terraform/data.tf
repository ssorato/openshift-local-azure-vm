data "http" "myip" {
  url = "http://ifconfig.me"
}

data "azurerm_resource_group" "azure_rg" {
  name = var.azure_rg
}

data "azurerm_virtual_network" "rg_vnet" {
  name                = var.rg_vnet
  resource_group_name = data.azurerm_resource_group.azure_rg.name
}

data "azurerm_subnet" "rg_subnet" {
  name                 = var.rg_subnet
  virtual_network_name = data.azurerm_virtual_network.rg_vnet.name
  resource_group_name  = data.azurerm_resource_group.azure_rg.name
}
