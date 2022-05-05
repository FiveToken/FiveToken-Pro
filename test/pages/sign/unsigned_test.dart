import 'package:fil/bloc/unsign/unsign_bloc.dart';
import 'package:fil/pages/sign/unsigned.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUnsignBloc extends Mock implements UnsignBloc {}

void main() {
  UnsignBloc bloc1 = MockUnsignBloc();
  bloc1..add(SetUnsignEvent(advanced: true));
  testWidgets('test render unsigned page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: UnsignedMessage(),
    ));
  });
}