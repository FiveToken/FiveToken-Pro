import 'package:fil/index.dart';
import 'package:mockito/mockito.dart';

import 'widgets/dialog_test.dart';

class MockBox<T> extends Mock implements Box<T> {}

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

void mockStore() {
  Global.store = MockSharedPreferences();
}

void putStore() {
  Get.put(StoreController());
}
