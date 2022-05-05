import 'package:fil/models/host.dart';
import 'package:fil/models/nonce.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate model Host", () async {
    var json = {
      "time": 1,
      "value": 1,
    };
    var storeMes = Nonce.fromJson(json);
    var nonce1 = Nonce(time: 0, value: 0);
    var jsonNonce = nonce1.toJson();
    var res3 = storeMes.toJson();
    var res4 = Nonce(time: 1, value: 1);
    expect(storeMes.time, 1);
    expect(nonce1.time, 0);
    expect(jsonNonce['value'], 0);
    var res1 = CacheGas(
      feeCap: '',
      premium: '',
      cid: '',
      gasLimit: 10,
    );
    expect(res1.gasLimit, 10);

    var balanceNonce = BalanceNonce(nonce: 1, balance: '');
    expect(balanceNonce.nonce, 1);
  });
}
