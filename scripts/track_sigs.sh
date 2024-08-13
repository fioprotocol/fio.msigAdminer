#!/bin/bash
################################################################################
# MSIG Console Manager
#
# Scrip Created by http://CryptoLions.io
# For FIO Blockchain
#
# Check Readme for more info.
#
# https://github.com/CryptoLions/MSIG_console_manager/tree/FIO
#
################################################################################

#set -x

CLIO=$( jq -r '.clio' "msig_config.json" )
NODEHOST=$( jq -r '.nodeHost' "msig_config.json" )

proposer=$( jq -r '.proposer' "msig_config.json" )
proposalNames=$( jq -r '.proposalNames' "msig_config.json" )

echo
echo Proposer: $proposer
echo

myarr=$($CLIO -u $NODEHOST get table eosio.msig $proposer approvals2 -L r211addactns -l 1 | jq -r '.rows[0].requested_approvals[].level.actor')
sorted=($(printf '%s\n' "${myarr[@]}"|sort))
echo "Requested Approvals: ${sorted[*]}"
echo
echo "Provided Approvals:"
echo -e "\tProposal\t\tCount"
echo -e "\t--------\t\t-----"
mycounts=()
for proposalName in $proposalNames; do
  count=$($CLIO -u $NODEHOST get table eosio.msig $proposer approvals2 -L $proposalName -l 1 | jq '.rows[0].provided_approvals | length')
  mycounts+=${count}

  myarr=$($CLIO -u $NODEHOST get table eosio.msig $proposer approvals2 -L $proposalName -l 1 | jq -r '.rows[0].provided_approvals[].level.actor')
  sorted=($(printf '%s\n' "${myarr[@]}"|sort))

  echo -e "\t$proposalName\t\t$count\t${sorted[*]}"
done

# ./clio.sh get table eosio.msig fio1uipge5sr approvals2 -L r211addactns -l 1 | jq '.rows[0].provided_approvals[].level'
#{
#  "actor": "bxb2lvjyevng",
#  "permission": "active"
#}
#{
#  "actor": "cjk2eoa5a4bg",
#  "permission": "active"
#}
#./clio.sh get table eosio.msig fio1uipge5sr approvals2 -L r211addactns -l 1 | jq '.rows[0].provided_approvals[].level.actor'
#"uret1dkc424x"
#"wrcjejslfplp"
#"hislmnfx13ya"
#"gtgkdpybvdnb"
#"lion4uxxfbqo"
#"zw4ndejblefr"
#"bxb2lvjyevng"
#"cjk2eoa5a4bg"

#myarr1=$(./clio.sh get table eosio.msig fio1uipge5sr approvals2 -L r211addactns -l 1 | jq '.rows[0].provided_approvals[].level.actor')
#myarr2=$(./clio.sh get table eosio.msig fio1uipge5sr approvals2 -L r211exeactns -l 1 | jq '.rows[0].provided_approvals[].level.actor')
#sorted1=($(printf '%s\n' "${myarr1[@]}"|sort))
#sorted2=($(printf '%s\n' "${myarr2[@]}"|sort))
#echo ${sorted1[@]} ${sorted2[@]} | tr ' ' '\n' | sort | uniq -u
#sorted_unique_ids=($(echo "${ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
