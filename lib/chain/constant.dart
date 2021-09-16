import 'package:fil/index.dart';

class FilecoinAccount {
  static String get f01 => Global.netPrefix + '01';
  static String get f02 => Global.netPrefix + '02';
  static String get f04 => Global.netPrefix + '04';
  static String get f099 => Global.netPrefix + '099';
}

class FilecoinMethod {
  static String get transfer => 'transfer';
  static String get send => 'send';
  static String get exec => 'Exec';
  static String get withdraw => 'WithdrawBalance';
  static String get createMiner => 'CreateMiner';
  static String get changeWorker => 'ChangeWorkerAddress';
  static String get changeOwner => 'ChangeOwnerAddress';
  static String get confirmUpdateWorkerKey => 'ConfirmUpdateWorkerKey';
  static List<String> get validMethods => [
        'transfer',
        'send',
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
}
