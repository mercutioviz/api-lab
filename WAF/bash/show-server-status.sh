#!/bin/bash
#
# show-server-status.sh
#
# Accepts WAF hostname/IP:port and displays server statuses
#  Assumes ${waftoken} contains the current login token
#

if [ -z "$1" ]
then
    host='51.143.38.93:8000'
else
    host="$1"
fi

response=`curl -s -X GET http://${host}/restapi/v3.1/services/HTTP?groups=Server\&parameters=status\&category=operational -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}`

echo "${response}"

