#!/bin/bash
#
# copy-waas-app.sh
#
# Accepts source app id and dest app id 
#  as CLI args and copies relevant configs
#

## If CLI args passed then assume they are the account_ids
if [ -z "$1" ]
then
    echo "Please supply the application ids as CLI arguments"
    exit 0
fi

if [ -z "$2" ]
then
    echo "Please supply the application ids as CLI arguments"
    exit 0
fi
src_app_id="1"
dst_app_id="2"
host='api.waas.barracudanetworks.com'
apiurl='/v2/waasapi/applications/'
method='GET'
headers='-H "accept: application/json" -H "Content-Type: application/json"'
response=`curl -s -X ${method} https://${host}${apiurl}/${src_app_id}/ ${headers} -H "auth-api: ${waastoken}"`

## DEBUG 
#echo "curl -s -X ${method} 'https://${host}${apiurl}' ${headers} -H \"auth-api: ${waastoken}\""

echo "${response}"

## Copy list
# Determine cert- auto or not
#  If not, copy cert
# HTTPS service settings 
# Iterate over components in src, copy to dst

