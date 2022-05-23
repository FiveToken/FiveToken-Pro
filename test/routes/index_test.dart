
import 'package:fil/routes/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var route = routes;
  test("generate route", () async {
    expect(route, routes);
  });
}