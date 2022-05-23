import 'package:fil/models/host.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("generate model Host", () async {
    var json = {
      "key": '0',
      "host": '0',
    };
    var storeMes = Host.fromJson(json);
    var host = Host(key: '1', value: '1');
    var hostJson = host.toJson();
    expect(storeMes.key, '0');
    expect(hostJson['key'], '1');
  });
}
