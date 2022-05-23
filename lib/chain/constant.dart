import 'package:fil/common/global.dart';
import 'package:fil/models/message.dart';

class FilecoinAccount {
  static String get f01 => Global.netPrefix + '01';
  static String get f02 => Global.netPrefix + '02';
  static String get f04 => Global.netPrefix + '04';
  static String get f099 => Global.netPrefix + '099';
}

class FilecoinMethod {
  static String get transfer => 'transfer';
  static String get send => 'Send';
  static String get exec => 'Exec';
  static String get withdraw => 'WithdrawBalance';
  static String get createMiner => 'CreateMiner';
  static String get changeWorker => 'ChangeWorkerAddress';
  static String get changeOwner => 'ChangeOwnerAddress';
  static String get approve => 'Approve';
  static String get propose => 'Propose';
  static String get confirmUpdateWorkerKey => 'ConfirmUpdateWorkerKey';
  static List<String> get validMethods => [
        'Send',
        'Exec',
        'WithdrawBalance',
        'CreateMiner',
        'ConfirmUpdateWorkerKey',
        'ChangeWorkerAddress',
        'ChangeOwnerAddress'
      ];
  static List<String> get idAddressMethods => [
        'Exec',
        'CreateMiner',
      ];
  static String getMethodNameByMessage(TMessage message) {
    var to = message.to;
    switch (message.method as int) {
      case 0:
        return send;
      case 2:
        return to == FilecoinAccount.f01 ? exec : propose;
      case 3:
        return changeOwner;
      case 16:
        return withdraw;
      case 21:
        return confirmUpdateWorkerKey;
      case 23:
        return changeWorker;
      default:
        return send;
    }
  }
}

class FilecoinAddressType {
  static String account = 'account';
  static String miner = 'storage_miner';
  static String multisig = 'multisig';
}

class MultiMessageStatus {
  static String applied = 'applied';
  static String pending = 'pending';
}
