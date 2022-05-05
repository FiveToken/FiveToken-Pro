
import 'package:fil/chain/filecoinWallet.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constant.dart';

void main() {
  testWidgets("test chain filecoinwalllet", (tester) async {
    var ck = FilecoinWallet.genPrivateKeyByMne(Mne);
    expect(ck, FilPrivate);
  });
}