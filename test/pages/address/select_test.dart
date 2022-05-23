import 'package:fil/bloc/address/address_bloc.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/address/select.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:provider/provider.dart';
import '../../box.dart';
import '../../constant.dart';

class MockAddressBloc extends Mock implements AddressBloc {}

void main() {
  AddressBloc bloc = MockAddressBloc();
  var box = mockAddressBoxbox();
  Get.put(StoreController());
  when(box.values).thenReturn([Wallet(address: FilAddr, label: WalletLabel)]);
  testWidgets('test render address book select page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: addressSelectPage,
      getPages: [
        GetPage(
            name: addressSelectPage,
            page: () => Provider(
                create: (_) => bloc..add(SetAddressEvent()),
                child: MultiBlocProvider(
                    providers: [BlocProvider<AddressBloc>.value(value: bloc)],
                    child: MaterialApp(
                      home: AddressBookSelectPage(),
                    ))))
      ],
    ));
    expect(find.text(WalletLabel), findsNothing);
  });
}
