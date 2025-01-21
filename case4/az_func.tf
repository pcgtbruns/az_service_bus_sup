// Service Plan
resource "azurerm_service_plan" "func-sp" {
  name                = "lurch_function_plan"
  resource_group_name = azurerm_resource_group.some_rg_func.name
  location            = azurerm_resource_group.some_rg_func.location
  os_type             = "Linux"
  sku_name            = "P1v2"

}

// Storage Account 

resource "azurerm_storage_account" "some_store" {
    name = "lurchstore"
    resource_group_name = azurerm_resource_group.some_rg_func.name
    location = azurerm_resource_group.some_rg_func.location
    account_tier = "Standard"
    account_replication_type = "LRS"
    identity {
      type = "SystemAssigned"
    }
    
}

// Storage container
resource "azurerm_storage_container" "some_container" {
  name                  = "lurchcontainer"
  storage_account_id    = azurerm_storage_account.some_store.id
}

// Function
resource "azurerm_linux_function_app" "az-func" {
  name                = "lurch-function"
  resource_group_name = azurerm_resource_group.some_rg_func.name
  location            = azurerm_resource_group.some_rg_func.location

  storage_account_name       = azurerm_storage_account.some_store.name
  service_plan_id            = azurerm_service_plan.func-sp.id
  identity {
    type = "SystemAssigned"
  }
  storage_uses_managed_identity = true
  public_network_access_enabled = false
  virtual_network_subnet_id = azurerm_subnet.func-subnet.id

  site_config {
    application_stack {
      python_version = "3.10"
    }
    always_on = true
    application_insights_connection_string = azurerm_application_insights.app_insight.connection_string
    application_insights_key = azurerm_application_insights.app_insight.instrumentation_key
  }

}

// Monitoring

// Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log_analytics_ws" {
  name                = "some-analytics-workspace"
  location            = azurerm_resource_group.some_rg_func.location
  resource_group_name = azurerm_resource_group.some_rg_func.name
  #sku                 = "Standard"
}

// Application Insights
resource "azurerm_application_insights" "app_insight" {
  name                = "some-insights"
  location            = azurerm_resource_group.some_rg_func.location
  resource_group_name = azurerm_resource_group.some_rg_func.name
  application_type    = "other"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_ws.id
  retention_in_days   = 30
}

// access rights

resource "azurerm_role_assignment" "some_accessrights" {
  scope                = azurerm_storage_account.some_store.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.az-func.identity[0].principal_id
}

resource "azurerm_role_assignment" "bus_access_rights" {
  scope                = azurerm_servicebus_namespace.some_bus.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_linux_function_app.az-func.identity[0].principal_id
}

resource "azurerm_app_service_connection" "bus_connection" {
  name               = "bus_serviceconnector"
  app_service_id     = azurerm_linux_function_app.az-func.id
  target_resource_id = azurerm_servicebus_namespace.some_bus.id
  authentication {
    type = "systemAssignedIdentity"
  }
}