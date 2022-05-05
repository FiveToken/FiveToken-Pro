import 'package:fil/models/host.dart';
import 'package:fil/models/nonce_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate model Host", () async {
    var json = {
      "time": 0,
      "value": [0],
      'salt': '1'
    };
    var storeMes = NonceUnit.fromJson(json);
    var res1 = storeMes.toJson();
    var nonceUnit = NonceUnit(time: 1000, salt: '123', value: [0,1]);
    expect(storeMes.salt, '1');
    expect(nonceUnit.salt, '123');
  });
}
