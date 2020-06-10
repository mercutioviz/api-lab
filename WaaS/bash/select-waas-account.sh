#!/bin/bash
#
# select-waas-account.sh
#
# Uses waas-login.sh and get-waas-accounts.sh to allow user to select which account to use
#   this_vnet=`echo "$vnet_json" | jq -r --arg 'I' $I '.[$I | tonumber] | .name'`

. ./waas-login.sh
echo "${waastoken}"
res=`./get-waas-accounts.sh`
current_acccount_index=`echo ${res} | jq -r '.current_account_idx`
