resource "azurerm_servicebus_namespace" "some_bus" {
  name                = "some-serv-bus"
  location            = azurerm_resource_group.some_rg_bus.location
  resource_group_name = azurerm_resource_group.some_rg_bus.name
  sku                 = "Premium"
  capacity            = 1
  premium_messaging_partitions = 1
  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = false
  
}

resource "azurerm_servicebus_topic" "some_topic" {
  name         = "some-topic"
  namespace_id = azurerm_servicebus_namespace.some_bus.id

  partitioning_enabled = true
}

resource "azurerm_servicebus_subscription" "some_sub" {
  name               = "some-subscription"
  topic_id           = azurerm_servicebus_topic.some_topic.id
  max_delivery_count = 1
}