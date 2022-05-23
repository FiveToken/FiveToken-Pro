

import 'package:fil/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("test widgets style", (tester) async {
    expect(CustomRadius.b2, BorderRadius.circular(6.0));
    expect(CustomRadius.b4, BorderRadius.circular(6.0));

    expect(CustomPadding.all10, EdgeInsets.all(10));
    expect(CustomPadding.v10, EdgeInsets.symmetric(vertical: 10));
    expect(CustomPadding.h10, EdgeInsets.symmetric(horizontal: 10));
    expect(CustomPadding.h12, EdgeInsets.symmetric(horizontal: 12));
    expect(CustomPadding.all15, EdgeInsets.all(15));
    expect(CustomPadding.v15, EdgeInsets.symmetric(vertical: 15));
    expect(CustomPadding.h15, EdgeInsets.symmetric(horizontal: 15));
    expect(CustomPadding.all20, EdgeInsets.all(20));
    expect(CustomPadding.v20, EdgeInsets.symmetric(vertical: 20));
    expect(CustomPadding.h20, EdgeInsets.symmetric(horizontal: 20));

    expect(CustomColor.brown, Color(0xffE8CC5C));
    expect(CustomColor.green, Color(0xff4FDF17));
  });
}