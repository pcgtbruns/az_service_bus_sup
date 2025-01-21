# Testcase 4

This testcase will be used to test whether the connection to the service bus is possible when using managed identity and public network access on both the function app and the service bus is deactivated. Both resources are deployed in their own vnet. Service bus will use private endpoint.

## Deployed Resources

- Functionapp
  - App Service Plan
  - Storage Account
- Service Bus
  - Topic
  - Subscription
- Vnet
  - Subnet with Delegation for Function App and Servie Endpoint set to `Microsoft.ServiceBus`
- Vnet
  - Subnet for private endpoints
  - Private Endpoint connected to Service Bus  
- Vnet peerings for both networks  

## Expectation

The function app should be able to connect to the service bus and receive messages from the service bus through private endpoint connection.

## Result

The function app is able to reach the service bus through its private endpoint as long as it is properly configured, meaning that a dns_a_record must be created and private-service-connection in place.