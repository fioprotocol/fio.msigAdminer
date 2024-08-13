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

#echo Multisig review
#./clio.sh multisig review "${proposer}" "${proposalName}"
echo Proposer table
#./clio.sh get table eosio.msig "${proposer}" proposal
# to get all proposal names
./clio.sh get table --limit 1000 eosio.msig "${proposer}" proposal | jq -r '[ .rows[] | .proposal_name ]'
echo
wait_on
echo Approvals2 table
#./clio.sh get table eosio.msig "${proposer}" approvals2
./clio.sh get table eosio.msig "${proposer}" approvals2 | jq -r '[ .rows[] | select(.proposal_name == "'${proposalName}'") ]'

echo
echo "To verify an mSig executed properly on-chain, run the command"
echo "curl --request POST \
--url http://127.0.0.1:8889/v1/chain/get_block \
--header 'accept: application/json' \
--header 'content-type: application/json' \
--data '{ \"block_num_or_id\": \"123456\" }'"
echo "  Replace '123456' with the actual block id of the transaction."
echo "  The block id may be retrieved from fio.bloks.io, or fio-test.bloks.io"
echo "    Goto More->All Multisigs, find the respective proposer and click 'Show Proposals"
echo "    Once mSig has been executed, one can view the transaction, and locate the block id"
echo
echo "To verify actions are on-chain, run the command"
echo "curl --request POST --url http://127.0.0.1:8889/v1/chain/get_actions --header 'accept: application/json' --header 'content-type: application/json'"
echo "  to pipe output to file append '>actions.out' to the command"
echo "  to grep from output file, run the command 'cat actions.out | egrep \"clearperm|remperm|addperm|updcryptkey|regdomadd|burndomain|newfioacc\""
echo
echo "To verify fees, run the command"
echo "./clio.sh get table -l 100 fio.fee fio.fee fiofees"
echo "  to pipe output to file append '>fees.json' to the command"
echo "  to grep from output file run the command 'cat fees.json | egrep \"new_fio_chain_account|update_encrypt_key|add_fio_permission|remove_fio_permission|register_fio_domain_address\""
echo
echo "To verify system account data, i.e. account existence, privilege, ram quota, etc., run the command"
echo "./clio.sh get account fio.perms"
echo "  to pipe out to file append '>newacct.out' or '| tee -a newacct.out' to the command"
echo
echo "To verify system account contract updates (set contract), run the abi/wasm comparison tool in fio.devtools, abi_wasm_hashout.sh, giving 'c' argument"
echo
