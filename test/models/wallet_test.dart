import 'package:fil/models/host.dart';
import 'package:fil/models/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate model Host", () async {
    var json = {
      'count': 1,
      'ck': '',
      'label': '',
      'address': '',
      'type': '',
      'readonly': 0,
      'walletType': 0,
      'owner': '',
      'balance': '',
      'skKek': '',
      'inAddressBook': false,
      'mne': '',
      'push': false
    };
    var storeMes = Wallet.fromJson(json);
    var res1 = storeMes.toJson();
    var res2 = storeMes.addr;
    var res3 = storeMes.addressWithNet;
    var res4 = storeMes.balanceNum;
    expect(storeMes.count, 1);

    var mres = MultiSignWallet.fromJson({
      'label': '',
      'id': '01248',
      'owner': '',
      'balance': '1',
      'threshold': 0,
      'signers': [''],
      'cid': '',
      'status': 0,
      'signerMap': {'sign': ''},
      'robustAddress': ''
    });
    var mres1 = mres.toJson();
    expect(mres.threshold, 0);
    expect(mres.addressWithNet, 'f1248');
    expect(mres1['id'], '01248');
    var sd = MultiWalletInfo(
        signerMap: {},
        balance: '1',
        robustAddress: '',
        approveRequired: 0
    );
    var sdJosn = sd.toJson();
    expect(sd.balance, '1');
    expect(sdJosn['balance'], '1');
  });
}
