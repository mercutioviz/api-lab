#!/bin/bash
#
# get-http-stats.sh
#
# Accepts WAF hostname/IP:port and prints HTTP stats
#  Assumes ${waftoken} contains the current login token
#

host='51.143.38.93:8000'

response=`curl -s -X GET http://${host}/restapi/v3.1/stats/http-stats -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}`
echo "${response}"

response=`curl -s -X GET http://${host}/restapi/v3.1/stats/ssl-stats -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}`
echo "${response}"

response=`curl -s -X GET http://${host}/restapi/v3.1/stats/system-stats -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}`
echo "${response}"

response=`curl -s -X GET http://${host}/restapi/v3.1/stats/attack-stats -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}`
echo "${response}"

response=`curl -s -X GET http://${host}/restapi/v3.1/stats/response-stats -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}`
echo "${response}"

