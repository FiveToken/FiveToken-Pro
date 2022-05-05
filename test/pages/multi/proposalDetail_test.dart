import 'package:fil/pages/multi/proposalDetail.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

void main() {
  Get.put(StoreController());
  testWidgets('test render multi proposalDetail page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: multiProposalDetailPage ,
        getPages: [
          GetPage(name: multiProposalDetailPage, page: () => MultiProposalDetailPage()),
        ]
    ));
  });
}