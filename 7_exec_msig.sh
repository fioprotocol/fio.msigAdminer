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

# source utils
CURRENT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
if [[ -e $CURRENT_DIR/utils.sh ]]; then
  source $CURRENT_DIR/utils.sh
fi
unlock_wallet

proposer=$( jq -r '.proposer' "0_CONFIG.json" )
proposalName=$( jq -r '.proposalName' "0_CONFIG.json" )
approver=$( jq -r '.approver' "0_CONFIG.json" )
feeExec=$( jq -r '.feeExec' "0_CONFIG.json" )

echo
echo /////////////////////---------- MultiSig Execution -----------///////////////////////////
echo // Configuration:
echo "//   proposer: $proposer"
echo "//   proposal: $proposalName"
echo "//   approver: $approver"
echo "//   fee     : $feeExec"
echo

if yes_or_no "Execute multisig for proposal $proposalName"; then
    echo "Executing $proposalName mSig, at `date`"
    echo "  using command: ./clio.sh multisig exec $proposer $proposalName $feeExec -p $approver"
    ./clio.sh multisig exec $proposer $proposalName $feeExec -p $approver
fi
