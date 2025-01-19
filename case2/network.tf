

resource "azurerm_virtual_network" "vnet" {
  name                = "some-vnet"
  address_space       = ["10.86.0.0/16"]
  location            = "germanywestcentral"
  resource_group_name = azurerm_resource_group.some_rg.name
}

// Subnets

resource "azurerm_subnet" "func-subnet" {
  name                              = "${azurerm_virtual_network.vnet.name}-func-subnet"
  address_prefixes                  = ["10.86.6.0/27"]
  resource_group_name               = azurerm_resource_group.some_rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  service_endpoints                 = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.ServiceBus"]
  depends_on                        = [azurerm_virtual_network.vnet]
  private_endpoint_network_policies = "Enabled"

     delegation {
    name = "delegate-func-subnet"

    service_delegation {
      name = "Microsoft.Web/serverFarms"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}


// Network Security Groups

resource "azurerm_network_security_group" "some-nsg" {
  name                = "${azurerm_virtual_network.vnet.name}-nsg"
  location            = azurerm_resource_group.some_rg.location
  resource_group_name = azurerm_resource_group.some_rg.name

}

// Network Security Rules

resource "azurerm_network_security_rule" "inbound-all-allow" {
  resource_group_name         = azurerm_resource_group.some_rg.name
  network_security_group_name = azurerm_network_security_group.some-nsg.name
  name                        = "AllowAll"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix     = "*"
  destination_address_prefix  = "*"
}

