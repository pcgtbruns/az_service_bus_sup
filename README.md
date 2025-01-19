# az_service_bus_sup

This repository contains test cases for the communication between service bus and azure function with different network setups.

## Prerequisites

- terraform
- az cli

## Deploying the test cases

Login to Azure using az cli and select the subscription you want to use. Afterwards enter the folder of the case to run and do:

```bash
terraform init && terraform apply`
```

The resources corresponding to the defined testcase will be deployed.

## Deploying function code

After `terraform` is done run `publish_app.sh`. Remember that public access on the function app needs to be enabled for the function code upload to work.

## Azure Function setup

Access the deployed function and go to `Settings->Environmental variables`. Here you need to change `AZURE_SERVICEBUS_FULLYQUALIFIEDNAMESPACE` to `SERVICEBUS__FULLYQUALIFIEDNAMESPACE`. Note the double underscore.

## Cleanup

When you are done with the testcases run `terraform destroy`
