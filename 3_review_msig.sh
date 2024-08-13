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

echo
echo /////////////////////---------- MultiSig Review -----------///////////////////////////
echo // Configuration:
echo "//   clio      : $CLIO"
echo "//   wallet url: $WALLETHOST"
echo "//   node url  : $NODEHOST"
echo "//   proposer  : $proposer"
echo "//   proposal  : $proposalName"
echo

./clio.sh multisig review $proposer $proposalName
