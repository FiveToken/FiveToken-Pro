import 'package:fil/index.dart';
import 'package:get/get.dart';

class StoreController extends GetxController {
  var wallet = Wallet().obs;
  var gas = Gas().obs;
  var cacheGas = Gas().obs;
  var message = StoreMessage().obs;
  var scanResult = ''.obs;
  var multiWallet = MultiSignWallet(signerMap: {}, signers: []).obs;
  var unsignedMessage = TMessage().obs;
  var afterPushPage = ''.obs;
  var n = (-1).obs;
  Gas get chainGas => cacheGas.value;
  Wallet get wal {
    return wallet.value;
  }

  MultiSignWallet get multiWal {
    return multiWallet.value;
  }

  StoreMessage get mes {
    return message.value;
  }

  String get maxFee {
    return getMaxFee(gas.value);
  }

  int get nonce {
    return n.value;
  }

  String get pushBackPage {
    return afterPushPage.value;
  }

  void setPushBackPage(String page) {
    afterPushPage.value = page;
  }

  String get maxFeeNum {
    var feeCap = gas.value.feeCap;
    var gasLimit = gas.value.gasLimit;

    return BigInt.from((double.parse(feeCap) * gasLimit)).toString();
  }

  TMessage get unsignedMes {
    return unsignedMessage.value;
  }

  bool get canPush => nonce != -1 && gas.value.valid;
  void setWallet(Wallet wal) async {
    wallet.value = Wallet.fromJson(wal.toJson());
  }

  void setMultiWallet(MultiSignWallet wal) async {
    multiWallet.value = MultiSignWallet.fromJson(wal.toJson());
  }

  void setUnsignedMessage(TMessage mes) {
    unsignedMessage.value = mes;
  }

  void deleteWallet() {
    wallet.value = null;
  }

  void changeWalletName(String label) {
    wallet.update((val) {
      val.label = label;
    });
  }

  void changeMultiWalletName(String label) {
    multiWallet.update((val) {
      val.label = label;
    });
  }

  void changeWalletAddress(String addr) {
    wallet.update((val) {
      val.address = addr;
    });
  }

  void changeWalletBalance(String balance) {
    wallet.update((val) {
      val.balance = balance;
    });
  }

  void changeMultiWalletBalance(String balance) {
    multiWallet.update((val) {
      val.balance = balance;
    });
  }

  void setGas(Gas g) {
    gas.value = g;
  }

  void setChainGas(Gas g) {
    cacheGas.value = g;
  }

  void setMessage(StoreMessage mes) {
    message.value = mes;
  }

  void scan(String res) {
    scanResult.value = res;
  }

  void setNonce(int nonce) {
    n.value = nonce;
  }
}

StoreController $store = Get.find();
