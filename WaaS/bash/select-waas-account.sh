#!/bin/bash
#
# select-waas-account.sh
#
# Uses waas-login.sh and get-waas-accounts.sh to allow user to select which account to use
#   this_vnet=`echo "$vnet_json" | jq -r --arg 'I' $I '.[$I | tonumber] | .name'`

. ./waas-login.sh
echo "${waastoken}"
res=`./get-waas-accounts.sh`
#OIFS=$IFS
#IFS=$'\n'
num_accts=`echo ${res} | jq -r '.accounts | length'`

if [[ ${num_accts} == 1 ]]
then 
    echo -n "Using the only account found: "
    echo $res | jq -r '.accounts[].name'
    echo
    exit 0
fi

echo "Found ${num_accts} accounts"
idx=`echo ${res} | jq -r '.current_account_idx'`
echo "Current account index: $idx"

#echo "DEBUG"
#echo ${res} | jq -r '.current_account_idx'

#IFS=$OIFS
