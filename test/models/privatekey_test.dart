import 'package:fil/models/host.dart';
import 'package:fil/models/private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate model Host", () async {
    var json = {
      "Type": '1',
      "PrivateKey": '0',
    };
    var storeMes = PrivateKey.fromMap(json);
    expect(storeMes.type, '1');
  });
}
