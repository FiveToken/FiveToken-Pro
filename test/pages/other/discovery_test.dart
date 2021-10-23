import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  testWidgets('test render discovery page', (tester)async{
    await tester.pumpWidget(MaterialApp(
      home: DiscoveryPage(),
    ));
    expect(find.byType(TapCard), findsNWidgets(2));
  });
}