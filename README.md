# FIO mSIG Adminer
  
Bash scripts to create/review/approve/cancel/execute msigs on the FIO blockchain, including DevNet, TestNet and MainNet.

_Note:_ if there is a backslash `\` in the data of a command, you may have to use a double backslash `\\` for the script to work.

# 1. Edit 0_CONFIG.json
- proposer: account name who creates msig
- proposalName: msig name (chars a-z.1-5 allowed only, max length 12 symbols)
- approver value also will be used as executer on msig execute.
- msig_expiration_h: value in hours how long msig will be active

- actions_list_file: list of actions which will be added to msig. One action per row. Do not include -s -j -d parametrs, they will be added automatically.

- requireBPsapprove: if set to 1 - top 30 BPS will be added as approvers automatically, if set to 0 please edit next parametr `approvers_list`
- approvers_list: list of msig approvers. Example `{\"actor\": \"acc1\", \"permission\": \"active\"},{\"actor\": \"acc2\", \"permission\": \"active\"}`

- clio: path to clio binary
- walletHost: your fio-wallet daemon information
- nodeHost: chain api node url

# 2. Prepare msig actions  
Prepare actions list which will be included in msig (in example file 1_actions_list)

# 3. Execute scipts  
Run scripts 2-7 depend on need

These scripts were originally created by CryptoLions.io but have been adapted and refactored extensively for use on the FIO blockchain. The CryptoLions repo may be found at https://github.com/CryptoLions/MSIG_console_manager.

# Development Testing
The following notes pertain to mSIG create, review, and execution in a development environment

First: the development nodeos must be run having both the default nodes as well as the 21 block producer setup. Follow the start prompts to set that up.

Second: the development nodeos must be updated to allow mSig creation, and execution. This only means that one must run fio.devtools/scripts/launch/09_update_permissions.sh from the command line
> bash ./scripts/launch/09_update_permissions.sh

While this should be the default it is not currently as fio.test must be validated to make sure no ill affects

Third: Use the config as found in fio.mSigAdminer/examples/0_CONFIG.json.localhost. This is also the default configuration for the msig tool.
- It will be beneficial to set autoApprove to '1'. This will help speed up the approval and execution process, otherwise, manual configration update will be required to load each approver separately.

Fourth: Create a link from /opt/FIO/bin/Contracts/last to the fio.contracts/build/contracts directory (ln -s /home/ubuntu/repos/fioprotocol/patch/fio.contracts/build/contracts /opt/FIO/bin/Contracts/last)

Note that the fio.contracts will need to be built with the current version (now old) as well as the 'New' version. To do this;
- Checkout the current release branch, i.e. 2.11.2, build, then backup the build directory (cp -r build build-old)
- Clean the build directory (rm -rf build/*), make updates, and build. Backup the build directory again (cp -r build build-new). Note that any updates will need to go into develop).
- Remove the build directory entirely, i.e. rm -rf build.
- Create a link to the old contracts, i.e. ln -s build-old build
- Start nodeos using fio.devtools start.sh script and load the 21 block producers
- Update the permissions as noted above (bash ./scripts/launch/09_update_permissions.sh) 
- Create a link to the new contracts that the msig adminer will use, i.e. ln -s <full path>/build-old /opt/FIO/bin/Contracts/last
- Create the mSigs as desired using the examples in examples directory (cp the example mSig action into actions/ and update the 0_Config.json to point to it)

