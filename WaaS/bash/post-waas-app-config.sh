#!/bin/bash
#
# post-waas-app-config.sh
#
# Accepts app id, api URL, and json filename as CLI args 
#  sends POST API call 
#

# Must have 3 CLI args
#  app id
#  api url
#  json file name

if [ -z "$3" ]
then
    echo "Please supply the following CLI arguments:"
    echo "  app id"
    echo "  api url"
    echo "  json file name"
    echo
    echo "Example:"
    echo
    echo "$0 1234 url_profiles url-profile-data.json"
    echo 
    exit 0
fi

host='api.waas.barracudanetworks.com'
apiurl='/v2/waasapi/applications/'
method='POST'
headers='-H "accept: application/json" -H "Content-Type: application/json"'
#response=`curl -s -X ${method} https://${host}${apiurl}$1/$2/ ${headers} -H "auth-api: ${waastoken}" -d @${3}`

## DEBUG 
echo "curl -s -X ${method} https://${host}${apiurl}$1/$2/ ${headers} -H \"auth-api: ${waastoken}\" -d @${3}"

echo "${response}"

