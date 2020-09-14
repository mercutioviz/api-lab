#!/bin/bash
#
# get-waas-app-logs.sh
#
# Accepts app id, log type as CLI arg and retrieves config
#

## If CLI arg passed then assume it is the application id
if [ -z "$2" ]
then
    echo "Please supply the application id and log type as CLI arguments with optional quickRange"
    echo "Example:"
    echo "  $0 1234 waf [r_1h|r_3h|r_24h|r_7d|r_14d|r_30d]"
    echo "  $0 1234 access [r_1h|r_3h|r_24h|r_7d|r_14d|r_30d]"
    exit 0
fi

logtype="$2"
if [ "$logtype" != "waf" ]
then
    logtype='access'
fi

host='api.waas.barracudanetworks.com'
apiurl='/v2/waasapi/applications/'
method='GET'
headers='-H "accept: application/json" -H "Content-Type: application/json"'
if [ -z "$3" ]
then
    qstring='?download=true'
else
    qstring="?download=true&quickRange=$3"
fi

response=`curl -s -X ${method} https://${host}${apiurl}/$1/${logtype}/logs/${qstring} ${headers} -H "auth-api: ${waastoken}"`

## DEBUG
#echo "curl -s -X ${method} 'https://${host}${apiurl}/$1/${logtype}/logs/${qstring}' ${headers} -H \"auth-api: ${waastoken}\""

echo "${response}"

