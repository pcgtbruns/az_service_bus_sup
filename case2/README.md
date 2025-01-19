# Testcase 2

This testcase will be used to test whether the connection to the service bus is possible when using managed identity and public network access on the function app is deactivated. `Azure Function App` will be on a Vnet. `Networking` for the service bus is set to `Selected networks` with the `Function App`'s virtual network beeing added to the exception list.

## Deployed Resources

- Functionapp
  - App Service Plan
  - Storage Account
- Service Bus
  - Topic
  - Subscription
- Vnet
  - Subnet with Delegation for Function App and Servie Endpoint set to `Microsoft.ServiceBus`

## Expectation

The function app should be able to connect to the service bus and receive messages from the service bus.

## Result

The function app is able to connect and receive messages from the service bus.