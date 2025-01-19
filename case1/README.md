# Testcase 1

This testcase will be used to test whether the connection to the service bus is possible when using managed identity. To ease the connection setup a `service connection`is used. Function app code is a simple service bus topic trigger.

## Message publisher

Message publishing is done through a local `azure function`.

## Deployed Resources

- Linux Functionapp
  - App Service Plan
  - Storage Account
- Service Bus
  - Topic
  - Subscription

## Expectation

The function app should be able to connect to the service bus and receive messages from the service bus.

## Result

1. When no access restriction is defined, the function app is able to communicate with the service bus using `managed identity`.

1. When having `public_network_access` disabled and no exception defined, the function app is not able to reach the service bus.

1. When having `public_network_access` disabled, and `Allow trusted Microsoft services to bypass this firewall` switched to `on`, communction with the service bus is also not possible.

**IMPORTANT**: The documentation found [here](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-ip-filtering) states, that `Azure Functions` are **NOT** on the `Trusted Services list`.

![image](img/error-log.png)

## Conclusion

When selecting any other option for networking than `public_network_access=true` the service bus is not reachable for the function app in its configuration with no `vnet` defined.

This is also stated in the documentation linked above:

```text
The following Microsoft services are required to be on a virtual network

Azure App Service
Azure Functions
```
