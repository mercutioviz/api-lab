#!/bin/bash
#
# waas-login.sh
#
# Accepts username and password then prints out the token
#
# NOTE: do a "dot include" to have ${waastoken} populated in the bash env
# Example:
# ". ./waas-login.sh" at the CLI
#

host='api.waas.barracudanetworks.com'
email='mercutio.viz@gmail.com'
pass='holycowthisiscrazy1!'
response=`curl -s -X POST https://${host}/v2/waasapi/api_login/ -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "password=${pass}&email=${email}&account_id=10943988"`

echo "${response}"

waastoken=`echo ${response} | jq -r '.' | grep 'key' | cut -b "10-" | sed -e 's/"//g'`
echo "waastoken=${waastoken}"
export "waastoken=${waastoken}"