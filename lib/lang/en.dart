const Map<String, String> EN_LANG = {
  "wallet": "Wallet",
  "enterName": "Please enter wallet name",
  "walletName": "Wallet name",
  "nameTooLong": "Wallet name cannot exceed 20 characters",
  "changeNameSucc": "Wallet name changed successfully",
  "walletAddr": "Wallet address",
  "changeWalletName": "Change wallet name",
  "selectLang": "Please select your language",
  "chinese": "Chinese",
  "addWallet": "Add wallet",
  "createWallet": "Create HD wallet",
  "importWallet": "Import wallet",
  "pkImport": "Import HD Private key",
  "mneImport": "Import HD Mnemonics",
  "importMne": "Import mnemonics",
  "import": "Import",
  "mne": "mnemonics",
  "copyMne": "Mnemonics copied successfully",
  "enterMne": "Please enter 12-digit mnemonics separated by spaces",
  "wrongMne": "Mnemonic input error, please check again",
  "importPk": "Import private key",
  "pk": "Private key",
  "copyPk": "Private key copied successfully",
  "wrongPk":
      "The current private key does not exist, please check that the private key is correct",
  "enterPk": "Please enter private key",
  "checkMneFail": "Creation failed, please check mnemonics",
  "checkMne": "Verify mnemonics",
  "clickMne": "Please click on mnemonics in order",
  "cut": "Do not take screenshots",
  "shareCut":
      "Do not share or store screenshot, it may be collected by third-party malware, resulting in loss of assets",
  "know": "Known",
  "writeMne": "Please write down mnemonics in order",
  "backupMne": "Back up mnemonics",
  "placeMne": "Keep mnemonics in a safe place, isolated from any network",
  "shareMne":
      "Do not share and store mnemonics on the network, such as mailbox, computer, Internet disk, chat tools.",
  "warn": "Backup reminder",
  "missMne": "Mnemonics loss will mean property loss from your wallet",
  "tip1":
      "Mnemonics are composed of English words, please write down and keep safe.",
  "tip2": "Mnemonics cannot be recovered once lost. Make sure to back it up.",
  "tip3":
      "If your device is missing, you can use mnemonics to recover, please have your pen and paper ready before you begin",
  "enterValidAddr": "Please enter a valid address",
  "enterTag": "Please enter contact remark, no more than 20 characters",
  "addAddrSucc": "Address added successfully",
  "changeAddrSucc": "Address changed successfully",
  "wrongAddr": "Address format error",
  "addAddr": "Add address",
  "manageAddr": "Manage address",
  "add": "Add",
  "save": "Save",
  "contactAddr": "Contact address",
  "copyAddr": "Address copied successfully",
  'changePass': "Change password",
  "remark": "Remark",
  "addrBook": "Address book",
  "deleteAddr": "Are you sure to delete this address",
  "confirmDelete":
      "confirmed to delete the frequently used address from the address book",
  "deleteSucc": "Delete successfully",
  "selectAddr": "Select receiving address",
  "filscan": "View on Filscan",
  "shareAddr": "Share my address",
  "set": "Setup",
  "feedback": "Feedback",
  "makeName": "Name your wallet",
  "sure": "Confirm",
  "createSucc": "Create successfully",
  "lang": "Language",
  "service": "Privacy Policy",
  'clause': 'Terms of Service',
  "version": "Version No",
  "pass": "Payment password",
  "setPass": "Set payment password",
  "enterPass": "Please enter password",
  "wrongPass": "Password error",
  "enterPassAgain": "Please enter password again",
  "enterValidPass": "8-20 digits,uppercase, lowercase, numbers",
  "diffPass": "Entered passwords differ",
  "oldPass": "Old payment password",
  "enterOldPass": "Please enter old payment password",
  "wrongOldPass": "Old payment password error",
  "changePassSucc": "Password changed successfully",
  "change": "Change",
  "newPass": "New payment password",
  "advanced": "Advanced setup",
  "fee": "Miner fee",
  "feeRate": "Miner fee rate",
  "fast": "Fast",
  "minute": "min",
  "normal": "Normal",
  "custom": "Customize",
  "maxFee": "Max service fee",
  "amount": "Quantity",
  "from": "Sending address",
  "to": "Receiving address",
  "cid": "Transaction ID",
  "height": "Block height",
  "more": "See more",
  "pending": "Waiting",
  "tradeSucc": "Transaction success",
  "tradeFail": "Transaction failed",
  "rec": "Receive",
  "send": "Send",
  'close': 'Close',
  "reced": "Received",
  "sended": "Sent",
  "sending": "Transaction sending",
  "sendFail": "Transaction sending failed",
  "enterValidAmount": "Please enter a valid transfer amount",
  "sendConfirm": "Send message confirmation",
  "enterAddr": "Please enter receiving address",
  "scan": "Scan QR code, go to FIL",
  "copy": "Copy",
  "copySucc": "Copy successfully",
  "share": "Share",
  "fail": "Failed",
  "finish": "Completed",
  "noData": "No transaction records at this time!",
  "pkExport": "Private key export",
  "mneExport": "Mnemonics export",
  "manageWallet": "Manage wallet",
  "exportMne": "Export mnemonics",
  "code": "QR Code",
  "notUseNet": "Do not transmit through network",
  "tip4":
      "Do not transmit through network, and if hacked, it will cause irreparable damage to assets. It is recommended to use an offline device to transmit by scanning the QR code",
  "offline": "Save offline",
  "tip5":
      "Do not save to mailbox, computer, Internet disk, chat tools and others, it is unsafe.",
  "onlyScan": "For direct scan only",
  "tip6":
      "Do not save, take screeshots or photoes of the QR code. Only for users to scan directly to import wallet in a safe environment",
  "useSafe": "Please use in a safe environment",
  "tip7":
      "Please use without anyone and cameras around you, the capture of QR code by others will result in irreparable damage to assets",
  "noPerson": "Please use without anyone around",
  "view": "View",
  "exportPk": "Export private key",
  "selectWallet": "Select wallet",
  "cancel": "Cancel",
  "delete": "Delete",
  "passCheck": "Verify password",
  'secp': "f1 address，(base onSecp256k1)",
  'bls': "f3 address，(base on Bls)",
  'selectAddrType': "Select Address Type",
  'today': 'Today',
  'yestoday': 'Yestoday',
  'hasPending':
      'There is unconfirmed transaction. Do you want to continue to transfer?',
  'speedup': 'Speed up unconfirmed transactions',
  'continueNew': 'Continue to send the new transaction',
  'connecting': 'Connecting',
  'connect': 'Connect',
  'disConnect': 'DisConnect',
  'approve': 'Approve',
  'reject': 'Reject',
  "errorExist": "Wallet address already exists",
  "errorNet":
      "The current network is unstable, please check that the connection is coorect",
  "errorSetGas": "Service fee error, please check network condition",
  "errorGetNonce": "Nonce value error, please check network condition",
  "errorLowBalance": "Insufficient balance",
  "errorAddr":
      "Address format error, please check that receiving address is correct",
  "errorFromAsTo": "Sending address cannot be the same as receiving address",
  'errorParams': 'Wrong Parameter',
  "next": "Next",
  'manage': 'Manage',
  'hd': "HD",
  'all': "All",
  'readonly': 'Readonly',
  'miner': 'Miner',
  'hdW': "HD wallet",
  'readonlyW': 'Readonly wallet',
  'minerW': 'Miner wallet',
  'offlineW': 'Offline wallet',
  'discovery': 'Discovery',
  'create': 'Create Wallet',
  'importReadonly': 'Import Readonly Wallet',
  'importMiner': 'Import Miner Wallet',
  'multisig': 'Multi-Sign',
  'multiWallet': 'Multi-Sign Wallet',
  'multiInfo': "Multi-Sign Info",
  'multiAccountInfo': 'Multi-Sign Account Info',
  'memberNum': 'No of Members',
  'threshold': 'No of Approval Applicants',
  'memberAddr': 'Member Address',
  'approvalPending': 'Pending Approval',
  'approvalSucc': 'Approved',
  'approvalFail': 'Failed to approve',
  'proposalPending': 'Pending Proposal',
  'proposalSucc': 'Proposed',
  'proposalFail': 'Failed to Propose',
  'waitApprove': 'Wait to Approve',
  'selectMulti': 'Select a Multi-sig Account',
  'nameMulti': 'Name your Multi-sig Account',
  'addMultiMember': 'Add your Multi-sig Member',
  'myAddr': 'My Address',
  'addMember': 'Add New Member',
  'approvalNum': 'No of Approvals',
  'lessThanMember':
      'No of Approval Applicants shall be fewer than that of Multi-sig Members',
  'select': 'Select',
  'propose': 'Propose',
  'createMulti': 'Create Multi-Sign Wallet',
  'importMulti': 'Import Multi-Sign Wallet',
  'multiAddr': 'Multi-sig Address',
  'enterMultiAddr': 'please enter multi-sig address',
  'searchProposal': 'Search for a Proposal',
  'enterPropsalId': 'please enter cid of proposal',
  'proposalInfo': 'Proposal Information',
  'proposalDetail': 'Proposal Detail',
  'approvalDetail': 'Approval Detail',
  'proposer': 'Proposer',
  'approver': 'Approver',
  'receiver': 'Receiver',
  'receiveAddr': 'Receiver Address',
  'approveId': 'Proposal Cid',
  'addReadonly': 'Add Readonly Wallet',
  'importSuccess': 'Import Succussfully',
  'notSigner': 'You are not the Signer',
  'searchFailed': 'search multi-sign wallet failed',
  'sameAsSigner': 'proposer can not approve',
  'getActorFailed': 'get signer address info failed',
  'errorCid': 'search proposal info failed, please check cid',
  'searchProposalFailed': 'search proposal info failed',
  'errorThreshold': 'please enter correct threshold',
  'bigThreshold': 'the threshold cannot exceed the number of signers',
  'errorSigner': 'please enter correct addresee',
  'wrongNonce': 'wrong nonce value',
  'lowFeeCap': 'gas fee cap too low',
  'capLessThanPremium': "'GasFeeCap' less than 'GasPremium'",
  'wrongSignature': 'wrong signature',
  'pushFail': 'Push Failed',
  'pushSuccess': 'Push Successfully',
  'enterOwner': 'please enter owner address',
  'enterWorker': 'please enter  worker address ',
  'enterController': 'please enter controller address',
  'owner': 'Owner ID',
  'minerAddr': 'Miner Address',
  'hasPendingNew':
      'You have pending message. Please confirm whether you need to create new one now',
  'makeNew': 'Continue to create new message',
  'enterFrom': 'enter from address',
  'first': 'Step 1- Create Message',
  'second': 'Step 2- Sign Message',
  'third': 'Step 3- Push Message',
  'op': 'Operationn',
  'worker': 'Worker Address',
  'controller': 'Controller Address',
  'addController': 'Add controller',
  'sign': 'Sign Message',
  'offlineSign':
      'Sign message via related offline signature wallet. Open the offline signature wallet and scan the QR code below to make the signature',
  'viewDetail': 'View Detail',
  'transfer': 'Transfer',
  'withdraw': 'Withdraw',
  'changeWorker': 'ChangeWorker',
  'createMiner': 'CreateMiner',
  'changeOwner': 'ChangeOwner',
  'clickCode': 'Click here to scan the QR code',
  'scanSign':
      'Scan the QR code generated by the signed offline signature wallet',
  'errorMesFormat': 'wrong message format',
  'signBtn': 'Sign',
  'exitAdvance': 'Exit',
  'useCurSign':
      'Scan unsigned QR code via current wallet to complete the signature.',
  'hasSign': "Message Signed",
  'useReadonly':
      'Send message via read-only wallet. Open read-only wallet and scan QR code to send message',
  'notOnline':
      'This is an offline signature wallet. Please don’t connect to the internet to ensure the security of private keys / mnemonic words',
  'latestVersion': 'Latest',
  'fromNotMatch': 'The from address does not match the signature address',
  "metaLock": "Locked Fund",
  "metaPledge": "Initial Pledge",
  "metaDeposit": "PreDeposit",
  "metaAvailable": "Available",
  "metaQuality": "AdjPower",
  "metaRewards": "Total Rewards",
  "metaRaw": 'RawBytePower',
  "metaPercent": 'Power Rate',
  "metaRank": 'Rank',
  "metaBlocks": 'Total Blocks',
  "metaSectorSize": 'Sector Size',
  "metaSectorStatus": 'Sector Status',
  "allSector": "Total",
  "faultSector": 'Faults',
  "validSector": 'Proving',
  "precommitSector": 'Recoveries',
  "yesBlock": "Block Rewards",
  "yesRewards": "Total Rewards",
  "yesWorker": "Worker GasFee",
  "yesController": "Controller GasFee",
  "yesSector": "Sector Increase",
  "yesPledge": "Initial Pledge",
  "yesTitle": "Yesterday's Statistics",
  "yesPowerIncr": 'Power Increase',
  "yesGas": 'Gas Fee',
  "yesPerT": 'Consume',
  "yesLucky": 'Lucky',
  'missField': 'miss required field',
  'makeFail': 'make message fail',
  'off': 'Offline',
  'on': 'Online',
  'monitorRecharge': 'Deposit',
  'monitorChange': 'Modify Tag',
  'monitorTitle': 'Balance Monitor',
  'monitorGas': "Yestoday GasFee",
  'updateTips': 'Upgrade to the latest version ?',
  'updateInstall': 'Install',
  'updateTitle': 'Update',
  'updateIgnore': 'Ignore this version',
  'isLatest': "It's the latest version",
  'updateCheck': 'Check for update',
  'aboutWeb': 'Official Website',
  'aboutData': 'Data & Analytics',
  'wechat': "Service Wechat",
  'depositTips': 'Tips',
  'depositDes':
      'Choose offline to create  transfer message, then signed by your offline wallet, after you have signed it, then click Discover and choose Push Message function to Push message',
  'depositRecharge': 'FIL Deposit',
  'balance': 'Balance',
  'feeWave': 'The Fluctuation of Fee',
  'feeDes':
      'There is a huge differential between the service fee of current network and that of message creating. You can re-create the new message to avoid failure of message sending',
  'reMake': "Recreate the message",
  'continueSend': 'Continue to send message',
  'notification': 'Notification',
  'opSucc': 'Operation Success',
  'opFail': 'Operatio Fail',
  'inAccount': 'In-account transfer',
  'multiTag': 'Multi-sig Adrress Tag',
  'mesMake': 'Message Create',
  'mesPush': 'Message Push',
  'selectPurpose': 'Select your Propose',
  'onlineMode': 'The wallet will connect to the internet',
  'offlineMode': 'The wallet will not connect to the internet ',
  "method": "Method ID",
  'about': 'About',
  'detail': 'Detail',
  'errorUnsigned': 'The message hasn’t been signed. Please go back to Step 2',
  'sectorType': 'Sector Type',
  'workerBls': 'The worker address shall begin with f3',
  'params': 'Params',
  'selectMiner':'Select Miner'
};
