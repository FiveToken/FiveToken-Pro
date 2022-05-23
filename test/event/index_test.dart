
import 'package:fil/event/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String refreshKey = 'refreshKey';
  var event = ShouldRefreshEvent(refreshKey: refreshKey);
  test("generate event", () async {
    expect(event.refreshKey, refreshKey);
  });
}