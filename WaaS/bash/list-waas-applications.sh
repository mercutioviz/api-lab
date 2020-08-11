#!/bin/bash
#
# list-waas-applications.sh
#
# Lists applications for the current user/account_id
#  Shows id and name
#

host='api.waas.barracudanetworks.com'
apiurl='/v2/waasapi/applications/'
method='GET'
headers='-H "accept: application/json" -H "Content-Type: application/json"'
response=`curl -s -X ${method} https://${host}${apiurl} ${headers} -H "auth-api: ${waastoken}" | jq '.results[] | {"id": .id, "name": .name}'`

echo "${response}"

