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
feeApprove=$( jq -r '.feeApprove' "0_CONFIG.json" )

echo
echo /////////////////////---------- MultiSig Approval -----------///////////////////////////
echo // Configuration:
echo "//   proposer: $proposer"
echo "//   proposal: $proposalName"
echo "//   approver: $approver"
echo "//   fee     : $feeApprove"
echo

if yes_or_no "Approve multisig for proposal $proposalName"; then
    echo "Approving $proposalName mSig, at `date`"
    echo "  using command: ./clio.sh multisig approve $proposer $proposalName '{\"actor\": \"$approver\", \"permission\": \"active\"}' $feeApprove -p $approver"
    ./clio.sh multisig approve $proposer $proposalName '{"actor": "$approver", "permission": "active"}' $feeApprove -p $approver
fi
