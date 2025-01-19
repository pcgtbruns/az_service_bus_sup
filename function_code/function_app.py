import azure.functions as func
import datetime
import json
import logging

app = func.FunctionApp()


@app.service_bus_topic_trigger(arg_name="azservicebus", subscription_name="some-subscription", topic_name="some-topic",
                               connection="SERVICEBUS") 
def servicebus_topic_trigger(azservicebus: func.ServiceBusMessage):
    logging.info('Python ServiceBus Topic trigger processed a message: %s',
                azservicebus.get_body().decode('utf-8'))
