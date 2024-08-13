#!/usr/bin/env bash
#set -x

# source utils
SCRIPT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
if [[ -e $SCRIPT_DIR/utils.sh ]]; then
  source $SCRIPT_DIR/utils.sh
fi
CURRENT_DIR=$(pwd -P)
if [[ -e $CURRENT_DIR/utils.sh ]]; then
  source $CURRENT_DIR/utils.sh
fi

echo
proposer=$( jq -r '.proposer' "0_CONFIG.json" )
proposalName=$( jq -r '.proposalName' "0_CONFIG.json" )
if [[ -z "$proposer" || -z "$proposalName" ]]; then
  echo "proposer and/or proposalName is not defined"
  exit 1
fi

if [[ -e "${proposalName}"_review.json || -e "${proposalName}"_proposal.json || -e "${proposalName}"_approvals2.json ]]; then
  echo "Capture files exist for msig ${proposalName} and will be overwritten"
  wait_on
  rm -f ${proposalName}_review.json "${proposalName}"_proposal.json "${proposalName}"_approvals2.json
fi

echo -n "Capturing proposal data using clio multisig review..."
#./3_review_msig.sh | tee -a "${proposalName}"_review.json
./3_review_msig.sh >"${proposalName}"_review.json
echo done
echo
sleep 1

echo -n "Capturing proposal data using clio get table on the proposal table..."
#./clio.sh get table eosio.msig "${proposer}" proposal | tee -a "${proposalName}"_proposal.json
./clio.sh get table eosio.msig "${proposer}" proposal | jq -r '[ .rows[] | select(.proposal_name == "'${proposalName}'") ]' >"${proposalName}"_proposal.json
echo done
echo
sleep 1

echo -n "Capturing approval data using clio get table on the approvals2 table..."
#./clio.sh get table eosio.msig "${proposer}" approvals2 | tee -a "${proposalName}"_approvals2.json
./clio.sh get table eosio.msig "${proposer}" approvals2 | jq -r '[ .rows[] | select(.proposal_name == "'${proposalName}'") ]' >"${proposalName}"_approvals2.json
echo done

echo
echo "To verify the on-chain transaction, use bloks.io to get the transaction block, then run the following command replacing block nbr;"
echo -e "\tcurl --request POST --url ${api_url}/v1/chain/get_block --header 'accept: application/json' --header 'content-type: application/json' --data '{ \"block_num_or_id\": \"<block nbr>\" }'"
