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

proposer=$( jq -r '.proposer' "0_CONFIG.json" )
proposalName=$( jq -r '.proposalName' "0_CONFIG.json" )

./clio.sh get table eosio.msig $proposer approvals2 -L $proposalName -l 1 | jq '.rows[0].provided_approvals | length'
