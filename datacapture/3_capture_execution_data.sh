#!/usr/bin/env bash
#set -x

echo
proposer=$( jq -r '.proposer' "0_CONFIG.json" )
proposalName=$( jq -r '.proposalName' "0_CONFIG.json" )
if [[ -z "$proposer" || -z "$proposalName" ]]; then
  echo "proposer and/or proposalName is not defined"
  exit 1
fi

echo Multisig review
./clio.sh multisig review $proposer $proposalName
echo
echo Proposal table
./clio.sh get table eosio.msig "${proposer}" proposal
echo
echo Approvals2 table
./clio.sh get table eosio.msig "${proposer}" approvals2

echo
echo "To verify actions are on-chain, run the command"
echo "curl --request POST --url http://127.0.0.1:8889/v1/chain/get_actions --header 'accept: application/json' --header 'content-type: application/json'"
echo "  to pipe output to file append '>actions.out' to the command above"
echo "  to grep from output file, run the command 'cat actions.out | egrep \"clearperm|remperm|addperm|updcryptkey|regdomadd|burndomain|newfioacc\""
echo
echo "To verify fees, run the command"
echo "./clio.sh get table -l 100 fio.fee fio.fee fiofees"
echo "  to pipe output to file append '>fees.json' to the end"
echo "  to grep from output file run the command 'cat fees.json | egrep \"new_fio_chain_account|update_encrypt_key|add_fio_permission|remove_fio_permission|register_fio_domain_address\""
echo
echo "To verify system account data, i.e. account existence, privilege, ram quota, etc., run the command"
echo "./clio.sh get account fio.perms"
echo
echo "To verify system account contract updates (set contract), run the abi/wasm comparison tool in fio.devtools, abi_wasm_hashout.sh, giving 'c' argument"
echo
