import 'package:fil/models/host.dart';
import 'package:fil/models/message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/models/gas.dart';
void main() {
  test("generate model TMessage", () async {
    var json = {
      "Version": 1,
      'To': '',
      'From': '',
      'Value': '0',
      'GasFeeCap': '0',
      'GasPremium': '0',
      'GasLimit': 0,
      'Params': '',
      'Nonce': -1,
      'Args': null,
      'InnerArgs': null,
      'Method': 0
    };
    var storeMes = TMessage.fromJson(json);
    Gas gas = Gas(feeCap: '1', gasLimit: 2, premium: '3');
    storeMes.setGas(gas);
    var _json = storeMes.toJson();
    var bool1 = storeMes.valid;
    var maxFee = storeMes.maxFee;
    var mes1 = storeMes.toLotusMessage();
    expect(storeMes.version, 1);

    var sign = Signature.fromJson({'Type': 1, 'Data': ''});
    var res = sign.toJson();
    expect(sign.type, 1);

    var signed = SignedMessage.fromJson({
      'Message': {'from': '', 'to': ''},
      'Signature': {'Type': 1, 'Data': ''}
    });
    var res1 = signed.toJson();
    var res2 = signed.toLotusSignedMessage();
    expect(signed.message, signed.message);

    var storeUnsignedMessage =
        StoreUnsignedMessage(message: storeMes, time: '1');
    var storeUnsignedMessage1 = storeUnsignedMessage.toJson();
    expect(storeUnsignedMessage.time, '1');

    var storeSignedMessage = StoreSignedMessage(
      message: signed,
      time: '1',
      pending: 1,
      cid: '',
      nonce: 1
    );
    var storeSignedMessageJson = storeSignedMessage.toJson();
    var from = storeSignedMessage.from;
    var to = storeSignedMessage.to;
    var res11 = storeSignedMessage.toJson();
    expect(storeSignedMessage.time, '1');
    expect(storeSignedMessageJson['time'], '1');
  });
}
