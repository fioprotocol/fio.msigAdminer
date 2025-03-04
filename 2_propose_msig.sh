#!/bin/bash
################################################################################
# fio-msigAdminer
#
# Script originally created by http://CryptoLions.io for the FIO Blockchain
#   https://github.com/CryptoLions/MSIG_console_manager/tree/FIO
#
# Check Readme for more info; https://github.com/dapixio/fio-msigAdminer
#
################################################################################

#set -x

# source utils
CURRENT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
if [[ -e $CURRENT_DIR/utils.sh ]]; then
  source $CURRENT_DIR/utils.sh
fi
unlock_wallet

# parse config
CLIO=$( jq -r '.clio' "0_CONFIG.json" )
WALLETHOST=$( jq -r '.walletHost' "0_CONFIG.json" )
NODEHOST=$( jq -r '.nodeHost' "0_CONFIG.json" )

proposer=$( jq -r '.proposer' "0_CONFIG.json" )
proposalName=$( jq -r '.proposalName' "0_CONFIG.json" )
EXPIRATION_IN_H=$( jq -r '.msig_expiration_h' "0_CONFIG.json" )
actions_list=$( jq -r '.actions_list_file' "0_CONFIG.json" )
requireBPsapprove=$( jq -r '.requireBPsapprove' "0_CONFIG.json" )
approvers_list=$( jq -r '.approvers_list' "0_CONFIG.json" )

feePropose=$( jq -r '.feePropose' "0_CONFIG.json" )
feeApprove=$( jq -r '.feeApprove' "0_CONFIG.json" )
feeCancel=$( jq -r '.feeCancel' "0_CONFIG.json" )
feeExec=$( jq -r '.feeExec' "0_CONFIG.json" )

echo

# Proposal name validation
# Name should be less than 13 characters and only contains the following symbol .12345abcdefghijklmnopqrstuvwxyz
if [[ ${#proposalName} -gt 12 ]]; then
  echo "  ERROR! The proposal name has a max char length of 12."
  echo "  Format: Name should be 12 or less characters in length and only contain the following symbols .12345abcdefghijklmnopqrstuvwxyz"
  echo
  exit 1
fi
if [[ ! (${proposalName} =~ ^[.12345abcdefghijklmnopqrstuvwxyz]+$) ]]; then
  echo "  ERROR! The proposal name has invalid characters."
  echo "  Format: Name should be 12 or less characters in length and only contain the following symbols .12345abcdefghijklmnopqrstuvwxyz"
  echo
  exit 1
fi

if [[ ! -r "${actions_list}" ]]; then
  echo
  echo "  ERROR! Actions file, '${actions_list}', was NOT found! Exiting..."
  echo
  exit 1
fi

if [[ $requireBPsapprove -eq 1 ]]; then
    #$APPROVERS=$(./clio.sh system listproducers -j -l 30 | jq -r '.producers[] | ( "{\"actor\": \"" + .owner + "\", \"permission\": \"active\"}" )' | paste -s -d",")
    readarray -t producers < <(./clio.sh system listproducers -j -l 30 | jq -r '.producers[] | ( .owner )' )
    readarray -td '' sorted < <(printf '{"actor": "%s", "permission":"active"}\0' "${producers[@]}" | sort -z)
    APPROVERS=$(joinByChar , "${sorted[@]}")
else
    APPROVERS=$approvers_list
fi

expire_date="$(date -d "+$EXPIRATION_IN_H hour" +%Y-%m-%dT%H:%M:%S)"
echo /////////////////////---------- MultiSig Proposal -----------///////////////////////////
echo // Configuration:
echo "//   clio           : $CLIO"
echo "//   wallet url     : $WALLETHOST"
echo "//   node url       : $NODEHOST"
echo "//   proposer       : $proposer"
echo "//   proposal       : $proposalName"
echo "//   msig expiration: $expire_date"
echo "//   actions list   : $actions_list"
echo "//   approvers      : $APPROVERS"
echo
echo // Actions to be performed:
while read actions; do
    # Skip blank, empty, comment lines
    case "$actions" in \#*|"") continue ;; esac

    echo "//   action: ${actions}"
done < $actions_list
echo
wait_on

# Clean up any artifacts
rm -f ${proposalName}_trx.json

# Create TRX body using Any trx
#  -d,--dont-broadcast         don't broadcast transaction to the network (just print to stdout)
#  -j,--json                   print result as json
#  -s,--skip-sign              Specify if unlocked wallet keys should be used to sign transaction
TRX_BODY=$(./clio.sh push action eosio init '[1,"4,EOS"]' -p eosio -d -j -s 2>/dev/null)
TRX_BODY=$(echo $TRX_BODY | jq -c '.expiration=$expire | del(.actions[])' --arg expire "$expire_date")

# Create tx json
echo $TRX_BODY > ${proposalName}_trx.json

# Read actions from actions file and update tx json
while read actions; do
    # Skip comment lines
    case "$actions" in \#*|"") continue ;; esac

    echo "Processing action ${actions}...."
    act_res=$(eval $actions -d -j -s  2>/dev/null)
    echo $act_res > acts.json
    tAct=$(cat acts.json | jq '.actions' | jq .)
    echo $tAct > input.json
    R=$(jq  '.actions+=input' ${proposalName}_trx.json input.json )
    echo $R | jq . > ${proposalName}_trx.json
    rm ./acts.json
    rm ./input.json
done < $actions_list

echo
if yes_or_no "Create multisig for $proposalName"; then
    echo "Proposing $proposalName mSig, at `date`"
    echo "  using command: ./clio.sh multisig propose_trx $proposalName \"[$APPROVERS]\" $feePropose ${proposalName}_trx.json $proposer -p $proposer"
    ./clio.sh multisig propose_trx $proposalName "[$APPROVERS]" $feePropose ${proposalName}_trx.json $proposer -p $proposer
fi
