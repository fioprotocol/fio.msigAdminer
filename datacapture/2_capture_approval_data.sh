#!/usr/bin/env bash
#set -x

echo
proposer=$( jq -r '.proposer' "0_CONFIG.json" )
proposalName=$( jq -r '.proposalName' "0_CONFIG.json" )
if [[ -z "$proposer" || -z "$proposalName" ]]; then
  echo "proposer and/or proposalName is not defined"
  exit 1
fi

./clio.sh get table eosio.msig "${proposer}" approvals2 | tee -a "${proposalName}"_approvals2.json
