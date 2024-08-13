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
approver=$( jq -r '.approver' "0_CONFIG.json" )
autoApprove=$( jq -r '.autoApprove' "0_CONFIG.json" )

feeApprove=$( jq -r '.feeApprove' "0_CONFIG.json" )

# Init APPROVERS array with either list of producers (if autoApprove) or explicit approver from config
APPROVERS=
if [[ $autoApprove -eq 1 ]]; then
  readarray -t producers < <(./clio.sh system listproducers -j -l 30 | jq -r '.producers[] | ( .owner )' )
  readarray -td '' sorted < <(printf '%s\0' "${producers[@]}" | sort -z)
  APPROVERS=("${sorted[@]}")
else
  APPROVERS=( $approver )
fi
# Reset approver
unset approver

echo
echo /////////////////////---------- MultiSig Approval -----------///////////////////////////
echo // Configuration:
echo "//   clio       : $CLIO"
echo "//   wallet url : $WALLETHOST"
echo "//   node url   : $NODEHOST"
echo "//   proposer   : $proposer"
echo "//   proposal   : $proposalName"
echo "//   autoApprove: $autoApprove"
echo "//   approvers  : ${APPROVERS[*]}"
echo "//   fee        : $feeApprove"
echo

echo -n "Approve proposal '${proposalName}'? "
wait_on
INDEX=1
for approver in ${APPROVERS[@]}; do
  if yes_or_no "Sign as ${approver}"; then
    echo "Approving ${proposalName} at `date`"
    echo "  using command: ./clio.sh multisig approve $proposer $proposalName '{\"actor\": \"$approver\", \"permission\": \"active\"}' $feeApprove -p $approver"
    ./clio.sh multisig approve $proposer $proposalName '{"actor": "'$approver'", "permission": "active"}' $feeApprove -p $approver
    echo
    echo -n "Total Nbr of Approvals: "
    ./clio.sh get table eosio.msig $proposer approvals2 -L $proposalName -l 1 | jq '.rows[0].provided_approvals | length'
  fi
  echo
  echo -n "Nbr BPs left to sign: "
  echo $((15 - ${INDEX}))
  let INDEX=${INDEX}+1
  echo
done
