#!/bin/bash
#
# get-waas-accounts.sh
#
# Lists accounts for the current user
#

host='api.waas.barracudanetworks.com'
apiurl='/v2/waasapi/accounts/'
method='GET'
headers='-H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded"'
response=`curl -s -X ${method} https://${host}${apiurl} ${headers} -H "auth-api: ${waastoken}"`

## DEBUG 
#echo "curl -s -X ${method} https://${host}${apiurl} ${headers} ${auth}"

echo "${response}"

