import 'package:fil/models/cacheMessage.dart';
import 'package:fil/pages/main/messageItem.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

void main() {
  Get.put(StoreController());
  StoreMessage mes = StoreMessage();
  testWidgets('test main messageItem widget', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MessageItem(mes),
    ));
    expect(find.byType(Text), findsNWidgets(3));
  });

}