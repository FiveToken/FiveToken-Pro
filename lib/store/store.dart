import 'package:fil/common/utils.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/gas.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/wallet.dart';
import 'package:get/get.dart';

/// store controller
class StoreController extends GetxController {
  /// wallet
  var wallet = Wallet().obs;

  /// gas
  var gas = Gas().obs;

  /// cache gas
  var cacheGas = Gas().obs;

  /// message
  var message = StoreMessage().obs;

  /// scan result
  var scanResult = ''.obs;

  /// multi wallet
  var multiWallet = MultiSignWallet(signerMap: {}, signers: []).obs;

  /// unsigned message
  var unsignedMessage = TMessage().obs;

  /// after push page
  var afterPushPage = ''.obs;

  /// nonce
  var n = (-1).obs;

  /// confirm message
  var confirmMessage = TMessage().obs;

  /// chain gas
  Gas get chainGas => cacheGas.value;

  /// get wallet
  Wallet get wal {
    return wallet.value;
  }

  /// get address
  String get addr => wal.addressWithNet;

  /// get multi sign wallet
  MultiSignWallet get multiWal {
    return multiWallet.value;
  }

  /// get store message
  StoreMessage get mes {
    return message.value;
  }

  /// get confirm message
  TMessage get confirmMes => confirmMessage.value;

  /// get max fee
  String get maxFee {
    return getMaxFee(gas.value);
  }

  /// get nonce
  int get nonce {
    return n.value;
  }

  /// get push back
  String get pushBackPage {
    return afterPushPage.value;
  }

  /// set push back
  void setPushBackPage(String page) {
    afterPushPage.value = page;
  }

  /// get mas fee
  String get maxFeeNum {
    var feeCap = gas.value.feeCap;
    var gasLimit = gas.value.gasLimit;
    return BigInt.from((double.parse(feeCap) * gasLimit)).toString();
  }

  /// get unsigned message
  TMessage get unsignedMes {
    return unsignedMessage.value;
  }

  /// get can push
  bool get canPush => nonce != -1;

  /// set wallet
  void setWallet(Wallet wal) async {
    wallet.value = Wallet.fromJson(wal.toJson());
  }

  /// set multi wallet
  void setMultiWallet(MultiSignWallet wal) async {
    multiWallet.value = MultiSignWallet.fromJson(wal.toJson());
  }

  ///  set unsigned message
  void setUnsignedMessage(TMessage mes) {
    unsignedMessage.value = mes;
  }

  /// delete wallet
  void deleteWallet() {
    wallet.value = null;
  }

  /// change wallet name
  void changeWalletName(String label) {
    wallet.update((val) {
      val.label = label;
    });
  }

  /// change multi wallet name
  void changeMultiWalletName(String label) {
    multiWallet.update((val) {
      val.label = label;
    });
  }

  /// change wallet address
  void changeWalletAddress(String addr) {
    wallet.update((val) {
      val.address = addr;
    });
  }

  /// change wallet balance
  void changeWalletBalance(String balance) {
    wallet.update((val) {
      val.balance = balance;
    });
  }

  /// change multi wallet balance
  void changeMultiWalletBalance(String balance) {
    multiWallet.update((val) {
      val.balance = balance;
    });
  }

  /// set gas
  void setGas(Gas g) {
    gas.value = g;
  }

  /// set chain gas
  void setChainGas(Gas g) {
    cacheGas.value = g;
  }

  /// set message
  void setMessage(StoreMessage mes) {
    message.value = mes;
  }

  /// set scan
  void scan(String res) {
    scanResult.value = res;
  }

  /// set nonce
  void setNonce(int nonce) {
    n.value = nonce;
  }

  /// set confirm message
  void setConfirmMessage(TMessage message) {
    confirmMessage.value = message;
  }
}

/// export store
StoreController $store = Get.find();
