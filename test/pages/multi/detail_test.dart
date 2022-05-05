import 'package:fil/bloc/multiDetail/multi_detail_bloc.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/multi/detail.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../box.dart';
import '../../constant.dart';
import '../../provider.dart';

class MockMultiDetailBloc extends Mock implements MultiDetailBloc {}

class MockSharedPreferences extends Mock implements SharedPreferences {
  setString(any, any2) {}
  getString(any) {
    return '';
  }
}

void main() {
  MultiDetailBloc bloc = MockMultiDetailBloc();
  var store = MockSharedPreferences();
  var adapter = mockProvider();
  Global.store = store;
  putStore();
  $store.setMultiWallet(
      MultiSignWallet(id: 'f0121', signers: [FilAddr, FilAddr]));
  testWidgets('test render multi detail page', (tester) async {
    adapter
      ..onGet(FilecoinProvider.multiPath, (request) {
        request.reply(200, {
          'code': 200,
          'data': {
            "id": "f0121",
            "address": "",
            "balance": "92048732000000000000000000",
            "nonce": 0,
            "signers": [
              {
                "f0103": "f1ceb34gnsc6qk5dt6n7xg6ycwzasjhbxm3iylkiy"
              },
              {
                "f0104": "f1meqrx2ijvgrdquybafmlwgszpmc34b3kg3nohvy"
              },
              {
                "f0105": "f1ovvm6oilbdsvbw27jhil3pcywrjuwiv5uzagq6i"
              },
              {
                "f0106": "f1cadxk4yywa7hfaiz3rs23t3wmyn7cjcdy5rtm4q"
              },
              {
                "f0107": "f3udf6vhs3xj7broosspzwjpbldee77qnrtzytpqrz2h6lfnx7sp3xwe3nn6lpg5eylpp3f7nmrqclt4zmd42a"
              },
              {
                "f0108": "f3thj7rtskyyvqw2i4v6xg6x32rgaf5pqpkgzcdreuapfl4revnez62geu4ens2aarapuppsmok5af3rzmtgua"
              },
              {
                "f0109": "f1t3atfumgpjhismj7pp3x63gpevxrsz4y2hgc4ci"
              }
            ],
            "approve_required": 3
          }
        });
      }, queryParameters: {'address': 'f0121'});
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: multiDetailPage,
      getPages: [
        GetPage(name: multiDetailPage, page: () => Provider(
        create: (_) => bloc..add(getMultiMessageDetailEvent($store.multiWal.addressWithNet)),
        child: MultiBlocProvider(
            providers: [BlocProvider<MultiDetailBloc>.value(value: bloc)],
            child: MaterialApp(
              home:  MultiDetailPage(),
            )
        )
       )
        )
      ],
    ));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    // expect(find.text(FilAddr), findsNWidgets(0));
  });
}
