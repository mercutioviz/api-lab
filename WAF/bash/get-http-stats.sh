#!/bin/bash
#
# get-http-stats.sh
#
# Accepts WAF hostname/IP:port and prints HTTP stats
#  Assumes ${waftoken} contains the current login token
#

if [ -z "$1" ]
then
    host='51.143.38.93:8000'
else
    host="$1"
fi

response=`curl -s -X GET http://${host}/restapi/v3.1/stats/http-stats -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}`

echo "${response}"

