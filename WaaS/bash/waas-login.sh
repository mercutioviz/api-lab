#!/bin/bash
#
# waas-login.sh
#
# Accepts username and password then prints out the token (account_id optional)
#
# NOTE: do a "dot include" to have ${waastoken} populated in the bash env
# Example:
# ". ./waas-login.sh" at the CLI
#

host='api.waas.barracudanetworks.com'
email='mercutio.viz@gmail.com'
pass=`cat ./creds.ignore`

## If CLI arg passed then assume it is the account_id
if [ -z "$1" ]
then
    response=`curl -s -X POST https://${host}/v2/waasapi/api_login/ -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "password=${pass}&email=${email}"`
else
    response=`curl -s -X POST https://${host}/v2/waasapi/api_login/ -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "password=${pass}&email=${email}&account_id=$1"`
fi

echo "${response}"

waastoken=`echo ${response} | jq -r '.' | grep 'key' | cut -b "10-" | sed -e 's/"//g'`
echo "waastoken=${waastoken}"
export "waastoken=${waastoken}"