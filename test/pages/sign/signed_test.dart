import 'package:fil/models/message.dart';
import 'package:fil/pages/sign/signed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var mes = SignedMessage(TMessage(), Signature(0, ''));
  testWidgets('test render signed page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignedMessageBody(mes),
    ));
  });
}