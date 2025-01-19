terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
}

  subscription_id = "2c12789e-7374-4443-92a4-a6e260376a10"
}

resource "azurerm_resource_group" "some_rg" {
  name     = "support-case3"
  location = "germanywestcentral"
}

// Service Plan
resource "azurerm_service_plan" "func-sp" {
  name                = "lurch_function_plan"
  resource_group_name = azurerm_resource_group.some_rg.name
  location            = azurerm_resource_group.some_rg.location
  os_type             = "Linux"
  sku_name            = "P1v2"

}

// Storage Account 

resource "azurerm_storage_account" "some_store" {
    name = "lurchstore"
    resource_group_name = azurerm_resource_group.some_rg.name
    location = azurerm_resource_group.some_rg.location
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
  resource_group_name = azurerm_resource_group.some_rg.name
  location            = azurerm_resource_group.some_rg.location

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
  location            = azurerm_resource_group.some_rg.location
  resource_group_name = azurerm_resource_group.some_rg.name
  #sku                 = "Standard"
}

// Application Insights
resource "azurerm_application_insights" "app_insight" {
  name                = "some-insights"
  location            = azurerm_resource_group.some_rg.location
  resource_group_name = azurerm_resource_group.some_rg.name
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

resource "azurerm_servicebus_namespace" "some_bus" {
  name                = "some-serv-bus"
  location            = azurerm_resource_group.some_rg.location
  resource_group_name = azurerm_resource_group.some_rg.name
  sku                 = "Premium"
  capacity            = 1
  premium_messaging_partitions = 1
  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = false

  network_rule_set {
    network_rules {
      subnet_id = azurerm_subnet.func-subnet.id
    }
  }
  
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

// service connections

resource "azurerm_app_service_connection" "bus_connection" {
  name               = "bus_serviceconnector"
  app_service_id     = azurerm_linux_function_app.az-func.id
  target_resource_id = azurerm_servicebus_namespace.some_bus.id
  authentication {
    type = "systemAssignedIdentity"
  }
}



