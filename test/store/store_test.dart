
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/gas.dart';
import 'package:fil/models/message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/store/store.dart';
import '../constant.dart';

void main() {
  var store = StoreController();
  TMessage message = TMessage(from: FilAddr);
  StoreMessage storeMessage = StoreMessage();
  Gas gas = Gas();
  test("generate store", () async {
    expect(store.chainGas.gasLimit, 0);
    expect(store.multiWal.id, '');
    expect(store.mes.from, '');
    expect(store.maxFee, '0 FIL');
    expect(store.pushBackPage, '');
    expect(store.maxFeeNum, '0');
    expect(store.unsignedMes.to, '');
    store.setPushBackPage('/main');
    store.setUnsignedMessage(message);
    expect(store.unsignedMes.from, FilAddr);
    store.changeWalletName('Aa');
    expect(store.wal.label, 'Aa');
    store.changeMultiWalletName('Bb');
    expect(store.multiWal.label, 'Bb');
    store.changeWalletAddress(FilAddr);
    expect(store.wal.address, FilAddr);
    store.changeWalletBalance('100000');
    expect(store.wal.balance, '100000');
    store.changeMultiWalletBalance('200000');
    expect(store.multiWal.balance, '200000');
    store.setMessage(storeMessage);
    store.scan('1122');
    store.setChainGas(gas);
    store.deleteWallet();
    expect(store.wal, null);
  });
}