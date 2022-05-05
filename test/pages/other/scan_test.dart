import 'package:fil/pages/other/scan.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

void main() {
  Get.put(StoreController());
  testWidgets('test render scan page', (tester)async{
    await tester.pumpWidget(MaterialApp(
      home: ScanPage(),
    ));
  });
}