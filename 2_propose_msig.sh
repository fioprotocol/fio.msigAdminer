#!/bin/bash
################################################################################
# MSIG Console Manager
#
# Script Created by http://CryptoLions.io
# For FIO Blockchain
#
# Check Readme for more info.
#
# https://github.com/CryptoLions/MSIG_console_manager/tree/FIO
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

if [[ $requireBPsapprove -eq 1 ]]; then
    APPROVERS=$(./clio.sh system listproducers -j -l 30 | jq -r '.producers[] | ( "{\"actor\": \"" + .owner + "\", \"permission\": \"active\"}" )' | paste -s -d",")
else
    APPROVERS=$approvers_list
fi

expire_date="$(date -d "+$EXPIRATION_IN_H hour" +%Y-%m-%dT%H:%M:%S)"

echo
echo /////////////////////---------- MultiSig Proposal -----------///////////////////////////
echo // Configuration:
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

## Any trx just to create TRX Body
#  -d,--dont-broadcast         don't broadcast transaction to the network (just print to stdout)
#  -j,--json                   print result as json
#  -s,--skip-sign              Specify if unlocked wallet keys should be used to sign transaction
TRX_BODY=$(./clio.sh push action eosio init '[1,"4,EOS"]' -p eosio -d -j -s 2>/dev/null)
TRX_BODY=$(echo $TRX_BODY | jq -c '.expiration=$expire | del(.actions[])' --arg expire "$expire_date")

# Create tx json
rm ${proposalName}_trx.json
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

if yes_or_no "Create multisig for $proposalName"; then
    echo "Proposing $proposalName mSig, at `date`"
    echo "  using command: ./clio.sh multisig propose_trx $proposalName \"[$APPROVERS]\" $feePropose ${proposalName}_trx.json $proposer -p $proposer"
    ./clio.sh multisig propose_trx $proposalName "[$APPROVERS]" $feePropose ${proposalName}_trx.json $proposer -p $proposer
fi
