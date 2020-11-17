#!/bin/bash
#
# get-url-profiles.sh
#
# Dumps all URL profiles (app profiles) for the given WaaS app id
#  Supply the app id as a CLI argument. Ex:
#    ./get-url-profiles.sh 1234
#

## If CLI arg passed then assume it is the app id
if [ -z "$1" ]
then
    echo "Please provide the app id as a CLI argument"
else
    appid="$1"
fi

host='api.waas.barracudanetworks.com'
apiurl='/v2/waasapi/applications/'
method='GET'
headers='-H "accept: application/json" -H "Content-Type: application/json"'
response=`curl -s -X ${method} https://${host}${apiurl}/${appid}/url_profiles/ ${headers} -H "auth-api: ${waastoken}"`

## DEBUG 
#echo "curl -s -X ${method} https://${host}${apiurl} ${headers} ${auth}"

echo "${response}"

