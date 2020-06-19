#!/bin/bash
#
# get-waas-applications.sh
#
# Lists applications for the current user/account_id
#

host='api.waas.barracudanetworks.com'
apiurl='/v2/waasapi/applications/'
method='GET'
headers='-H "accept: application/json" -H "Content-Type: application/json"'
response=`curl -s -X ${method} https://${host}${apiurl}/6592/ ${headers} -H "auth-api: ${waastoken}"`

## DEBUG 
#echo "curl -s -X ${method} https://${host}${apiurl} ${headers} ${auth}"

echo "${response}"

