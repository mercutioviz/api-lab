#!/bin/bash
#
# get-waas-app-config.sh
#
# Accepts app id as CLI arg and retrieves config
#

## If CLI arg passed then assume it is the application id
if [ -z "$1" ]
then
    echo "Please supply the application id as CLI argument"
    exit 0
fi

host='api.waas.barracudanetworks.com'
apiurl='/v2/waasapi/applications/'
method='GET'
headers='-H "accept: application/json" -H "Content-Type: application/json"'
response=`curl -s -X ${method} https://${host}${apiurl}/$1/ ${headers} -H "auth-api: ${waastoken}"`

## DEBUG 
#echo "curl -s -X ${method} 'https://${host}${apiurl}' ${headers} -H \"auth-api: ${waastoken}\""

echo "${response}"

