

import 'package:fil/repository/http/interceptors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var responseJson = {
    'data': {
      'id': 'f01248',
      'balance':'10000'
    },
    'code': 200,
    'msg': 'success'
  };
  var response = ResponseData.formJson(responseJson);
  var resJson = response.toJson();
  var toString = response.toString();
  testWidgets('test repository http page', (tester) async {
    expect(resJson, responseJson);
    expect(response.success, true);
  });
}