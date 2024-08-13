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

feeCancel=$( jq -r '.feeCancel' "0_CONFIG.json" )

echo
echo /////////////////////---------- MultiSig Cancelation -----------///////////////////////////
echo // Configuration:
echo "//   clio      : $CLIO"
echo "//   wallet url: $WALLETHOST"
echo "//   node url  : $NODEHOST"
echo "//   proposer  : $proposer"
echo "//   proposal  : $proposalName"
echo "//   fee       : $feeCancel"
echo

if yes_or_no "Cancel multisig for proposal $proposalName"; then
  echo "Canceling $proposalName mSig, at `date`"
  echo "  using command: ./clio.sh multisig cancel '{\"proposer\": \"$proposer\", \"proposal_name\": \"$proposalName\", \"canceler\": \"$proposer\", \"max_fee\": '$feeCancel'}' -p $proposer"
  ./clio.sh push action eosio.msig cancel '{"proposer": "'$proposer'", "proposal_name": "'$proposalName'", "canceler": "'$proposer'", "max_fee": '$feeCancel'}' -p $proposer
fi

