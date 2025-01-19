#!/bin/bash

echo "Publishing function app..."

cd function_code && func azure functionapp publish lurch-function && echo "Done."