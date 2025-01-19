output "service_bus_connection_string" {
  description = "Service Bus Connection String"
  value       = azurerm_servicebus_namespace.some_bus.default_primary_connection_string
  sensitive = true
}