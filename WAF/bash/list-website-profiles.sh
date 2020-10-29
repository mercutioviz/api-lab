#!/bin/bash
#
# list-website-profiles.sh
#
# Lists each website and the corresponding URL and param profiles
#

if [ -z "$1" ]
then
    host='51.143.38.93:8000'
else
    host="$1"
fi

websites=`curl -s -X GET http://${host}/restapi/v3.1/services -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}`
website_list=`echo ${websites} | jq -r '.data[].name'`

for website in `echo ${website_list}`; \
do echo "Looking up '${website}'" && \
 url_profiles=`curl -s -X GET http://${host}/restapi/v3.1/services/${website}/url-profiles -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}` && \
 url_profile_list=`echo ${url_profiles} | jq -r '.data[].name'` && \
 for url_profile in `echo ${url_profile_list}`; \
  do echo "  Pulling profile ${url_profile}" && \
  echo ${url_profiles} | jq ".data.${url_profile}" > ./${website}_${url_profile}.json && 
  param_profiles=`curl -s -X GET http://${host}/restapi/v3.1/services/${website}/url-profiles/${url_profile}/parameter-profiles -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}` && \
  param_profile_list=`echo ${param_profiles} | jq -r '.data[].name'` && \
  #echo ${param_profiles} | jq -r '.data[].name' && \
  for param_profile in `echo ${param_profile_list}`; \
   do echo "   Pulling param profile ${param_profile}" && \
   param_profile_data=`curl -s -X GET http://${host}/restapi/v3.1/services/${website}/url-profiles/${url_profile}/parameter-profiles/${param_profile} -H "accept: application/json" -H "Content-Type: application/json" -u ${waftoken}` && \
   echo ${param_profile_data} | jq '.data' > ./${website}_${url_profile}_PARM_${param_profile}.json ; done \
  ; \
  done \
done

