# Azure Examples

## Purpose
Provide small Azure deployment patterns that are easy to understand and validate.

## Resource Group Example
```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-sysadmin-field-guide"
  location = "East US"
}
```

## Virtual Network Example
```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-sysadmin-lab"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}
```

## Subnet Example
```hcl
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
```

## Validation
- resources appear in Azure
- naming is consistent
- CIDR ranges are correct
- plan output matches intent
