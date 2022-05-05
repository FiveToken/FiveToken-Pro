class WalletsType {
  static final normal = 0; //  common offline readonly address
  static final migrate = 1; // migrate address
  static final miner = 2; //  miner
}

class SignType {
  static final secp = 1; // secp
  static final bls = 2; //  bls
}

class SignStringType {
  static final secp = 'secp'; // secp
  static final bls = 'bls'; //  bls
}

class WalletType {
  static final all = 'all';
  static final common = 'hd';
  static final readonly = 'readonly';
  static final miner = 'miner';
}

class TransferType {
  static final all = 0;
  static final transferIn = 1;
  static final transferOut = 2;
}

class MultiTabs {
  static final proposal = 0;
  static final collection = 1;
}

class MethodTypeOfMessage {
  static final create = 0;
  static final proposal = 2;
  static final proposalDetail = 3;
}

class RechargeRadio {
  static final offLine = 'offLine';
  static final onLine = 'onLine';
}

class Timeout {
  static final short = 30000;
  static final medium = 300000;
  static final long = 1000000;
}
