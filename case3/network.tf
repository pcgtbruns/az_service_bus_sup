

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

resource "azurerm_subnet" "pep-subnet" {
  name                              = "${azurerm_virtual_network.vnet.name}-pep-subnet"
  address_prefixes                  = ["10.86.5.0/27"]
  resource_group_name               = azurerm_resource_group.some_rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  service_endpoints                 = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.ServiceBus"]
  depends_on                        = [azurerm_virtual_network.vnet]
  private_endpoint_network_policies = "Enabled"
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

// Private endpoint

resource "azurerm_private_endpoint" "bus-pep" {
  custom_network_interface_name = "${azurerm_servicebus_namespace.some_bus.name}-pep-nic"
  location                      = azurerm_resource_group.some_rg.location
  name                          = "${azurerm_servicebus_namespace.some_bus.name}-pep"
  resource_group_name           = azurerm_resource_group.some_rg.name
  subnet_id                     = azurerm_subnet.pep-subnet.id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = ["/subscriptions/2c12789e-7374-4443-92a4-a6e260376a10/resourceGroups/support-case3/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"]
  }
  private_service_connection {
    is_manual_connection           = false
    name                           = "${azurerm_servicebus_namespace.some_bus.name}-psc"
    private_connection_resource_id = azurerm_servicebus_namespace.some_bus.id
    subresource_names              = ["namespace"]
  }
  depends_on = [
    azurerm_private_dns_zone.dns_zone,
    azurerm_subnet.pep-subnet,
  ]
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.some_rg.name
  depends_on = [
    azurerm_resource_group.some_rg,
  ]
}
resource "azurerm_private_dns_a_record" "dns_a_record" {
  name                = "some-serv-bus"
  records             = ["10.86.5.5"]
  resource_group_name = azurerm_resource_group.some_rg.name
  ttl                 = 10
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  depends_on = [
    azurerm_private_dns_zone.dns_zone,
  ]
}
resource "azurerm_private_dns_zone_virtual_network_link" "priv_network_link" {
  name                  = "${azurerm_servicebus_namespace.some_bus.name}-net-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  resource_group_name   = azurerm_resource_group.some_rg.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  depends_on = [
    azurerm_private_dns_zone.dns_zone,
    azurerm_virtual_network.vnet,
  ]
}







