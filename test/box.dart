import 'package:fil/common/global.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/models/nonce.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/store/store.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'widgets/dialog_test.dart';

class MockBox<T> extends Mock implements Box<T> {
  // containsKey(any) {}
}

MockBox<Wallet> mockWalletbox() {
  var box = MockBox<Wallet>();
  OpenedBox.addressInsance = box;
  return box;
}

MockBox<Wallet> mockAddressBoxbox() {
  var box = MockBox<Wallet>();
  OpenedBox.addressBookInsance = box;
  return box;
}

MockBox<Nonce> mockNoncebox() {
  var box = MockBox<Nonce>();
  OpenedBox.nonceInsance = box;
  return box;
}

MockBox<StoreMessage> mockMessagebox() {
  var box = MockBox<StoreMessage>();
  OpenedBox.messageInsance = box;
  return box;
}

MockBox<StoreSignedMessage> mockPushbox() {
  var box = MockBox<StoreSignedMessage>();
  OpenedBox.pushInsance = box;
  return box;
}

MockBox<MinerAddress> mockMinerAddressbox() {
  var box = MockBox<MinerAddress>();
  OpenedBox.minerAddressInstance = box;
  return box;
}

MockBox<MultiSignWallet> mockMultibox() {
  var box = MockBox<MultiSignWallet>();
  OpenedBox.multiInsance = box;
  return box;
}

MockBox<CacheMultiMessage> MockmultiProposeInstance(){
  var box = MockBox<CacheMultiMessage>();
  OpenedBox.multiProposeInstance = box;
  return box;
}

MockBox<MinerSelfBalance> MockminerBalanceInstance(){
  var box = MockBox<MinerSelfBalance>();
  OpenedBox.minerBalanceInstance = box;
  return box;
}

MockBox<MinerHistoricalStats> MockminerStatisticInstance(){
  var box = MockBox<MinerHistoricalStats>();
  OpenedBox.minerStatisticInstance = box;
  return box;
}

void mockStore() {
  Global.store = MockSharedPreferences();
}

void putStore() {
  Get.put(StoreController());
}
