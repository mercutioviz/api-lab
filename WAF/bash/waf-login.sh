#!/bin/bash
#
# waf-login.sh
#
# Accepts username and password and WAF hostname/IP:port and prints out the token
#
# NOTE: do a "dot include" to have ${waftoken} populated in the bash env
# Example:
# ". ./waf-login.sh" at the CLI
#

if [ -z "$1" ]
then
    host='51.143.38.93:8000'
else
    host="$1"
fi

user='wafapiuser'
pass='cloud2020'
response=`curl -s -X POST http://${host}/restapi/v3.1/login -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"password\": \"${pass}\", \"username\": \"${user}\"}"`

#echo "${response}"

waftoken=`echo ${response} | jq -r '.' | grep 'token' | cut -b "12-" | sed -e 's/n"/n:"/'`
echo "waftoken=${waftoken}"
export "waftoken=${waftoken}"
