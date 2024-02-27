#!/usr/bin/env bash

# source utils
CURRENT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
if [[ -e $CURRENT_DIR/utils.sh ]]; then
  source $CURRENT_DIR/utils.sh
fi
unlock_wallet

echo
CLIO=$( jq -r '.clio' "0_CONFIG.json" )
WALLETHOST=$( jq -r '.walletHost' "0_CONFIG.json" )
NODEHOST=$( jq -r '.nodeHost' "0_CONFIG.json" )
echo "clio: $CLIO, wallet host: $WALLETHOST, node host: $NODEHOST"

proposer=$( jq -r '.proposer' "0_CONFIG.json" )
approver=$( jq -r '.approver' "0_CONFIG.json" )
feeExec=$( jq -r '.feeExec' "0_CONFIG.json" )
echo "Proposer: $proposer, Max Fee: $feeExec, Approver: $approver"
echo

# Execute system contract first!
proposal="upd2nzrc1a"

if yes_or_no "Execute system contract proposal ${proposal}"; then
   echo "Executing System contract proposal: $proposal"
   $CLIO -u $NODEHOST --wallet-url $WALLETHOST multisig exec $proposer $proposal $feeExec -p $approver
fi
echo

if ! yes_or_no "Has System Contract proposal been executed"; then
   echo
   echo "The System Contract proposal has NOT been executed! Exiting..."
   exit 1
fi

# Now execute other contracts
echo
for proposal in upd2nzrc1b upd2nzrc1c upd2nzrc1d upd2nzrc1e upd2nzrc1f upd2nzrc1g; do
   if yes_or_no "Execute proposal ${proposal}"; then
      echo "Executing contract ${proposal}..."
      echo
      #/home/ubuntu/fio/3.5.x-dev/bin/clio -u https://api.fiotest.alohaeos.com --wallet-url http://localhost:8900 multisig exec 5du5xkgkki5x ${proposal} 400000000 -p nyvrxkxhiyql
      #./clio.sh multisig exec $proposer $proposal $feeExec -p $approver
      $CLIO -u $NODEHOST --wallet-url $WALLETHOST multisig exec $proposer $proposal $feeExec -p $approver
   fi
   echo
   wait_on
done
