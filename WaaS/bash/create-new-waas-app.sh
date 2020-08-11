#!/bin/bash
#
# create-new-waas-app.sh
#
# Accepts filename arg or reads in app.json data and creates a new WaaS app in the current account
#

host='api.waas.barracudanetworks.com'

## If CLI arg passed then assume it is the filename
if [ -z "$1" ]
then
    app_data_file='app.json'
else
    app_data_file="$1"
fi

echo "Creating new WaaS app from file ${app_data_file}"

response=`curl -s -X POST https://${host}/v2/waasapi/applications/ -H "accept: application/json" -H "Content-Type: application/json" -H "auth-api: ${waastoken}" -d "\@${app_data_file}"`

echo "${response}"
