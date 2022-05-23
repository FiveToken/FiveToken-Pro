import 'package:fil/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  testWidgets('test render common card', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CommonCard(Text(WalletLabel)),
    ));
    expect(find.text(WalletLabel), findsOneWidget);
    Container con = tester.widget(find.byType(Container));
    expect(con.decoration is BoxDecoration, true);
  });
  testWidgets('test render tap item card', (tester) async {
    var n = 0, n2 = 0;
    var card1 = CardItem(
      label: WalletLabel,
      onTap: () {
        n++;
      },
    );
    var card2 = CardItem(
      label: WalletLabel,
      onTap: () {
        n2--;
      },
    );
    await tester.pumpWidget(MaterialApp(
      home: TapCard(
        items: [card1, card2],
      ),
    ));
    expect(find.byType(CardItem), findsNWidgets(2));
    await tester.tap(find.byWidget(card1));
    expect(n, 1);
    await tester.tap(find.byWidget(card2));
    expect(n2, -1);
  });
}
