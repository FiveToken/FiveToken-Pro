import 'package:fil/bloc/multi/multi_bloc.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/data/preferences_manager.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/multi/main.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/main_test.mocks.dart';
import '../../box.dart';
import '../../constant.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../provider.dart';
import '../../widgets/dialog_test.dart';

class MockMultiBloc extends Mock implements MultiBloc {}
@GenerateMocks([PreferencesManagerX])
void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  var adapter = mockProvider();
  adapter
    ..onGet(FilecoinProvider.proposePath, (request) {
    request.reply(200, {
      'code': 200,
      'data': {
        "messages": [
          {
            "mid": "171948400377",
            "cid": "bafy2bzacec3pjodly62ohgpsstz4vj7viauqm2vnscemrsskx2eshslwxuios",
            "block_epoch": 1719484,
            "block_time": 1649890920,
            "from": "f1ceb34gnsc6qk5dt6n7xg6ycwzasjhbxm3iylkiy",
            "to": "f0121",
            "nonce": 4997,
            "status": "applied",
            "method_name": "Propose",
            "gas_fee": "799176155185460",
            "gas_limit": 3168808,
            "gas_used": 2561047,
            "base_fee_burn": "773649657267450",
            "gas_premium": "100145",
            "gas_fee_cap": "2925938369",
            "over_estimation_burn": "25209157640850",
            "params_params": "",
            "params_method": "Send",
            "params_txnid": 4,
            "params_json": "{\"To\": \"f1ngz5ix5on6ov4sd5epnqlyfvbenr6s76nqz7piy\", \"Value\": \"3000000000000000000000000\", \"Method\": 0, \"Params\": null}",
            "exit_code": 0,
            "approves": [
              {
                "mid": "171949200625",
                "cid": "bafy2bzacebbcxbkhjmibgeqqxswzty5262vsx7rhh2xmkswxetwkn653wdm7k",
                "block_epoch": 1719492,
                "block_time": 1649891160,
                "from": "f1meqrx2ijvgrdquybafmlwgszpmc34b3kg3nohvy",
                "to": "f0121",
                "nonce": 1325,
                "method_name": "",
                "gas_fee": "673596963184198",
                "gas_limit": 2591883,
                "gas_used": 2099507,
                "base_fee_burn": "652743889817884",
                "gas_premium": "100582",
                "gas_fee_cap": "3090256319",
                "over_estimation_burn": "20592376590408",
                "params_params": "",
                "params_method": "",
                "params_txnid": 4,
                "params_json": "",
                "return_json": "{\"Ret\": null, \"Code\": 0, \"Applied\": false}",
                "exit_code": 0
              },
              {
                "mid": "171950300200",
                "cid": "bafy2bzacecl27ugdjtdfmctvssqh3pptj5qvp7xfeu2amn3ci4opz25qzseqg",
                "block_epoch": 1719503,
                "block_time": 1649891490,
                "from": "f1ovvm6oilbdsvbw27jhil3pcywrjuwiv5uzagq6i",
                "to": "f0121",
                "nonce": 427,
                "method_name": "",
                "gas_fee": "1205325127481632",
                "gas_limit": 4190657,
                "gas_used": 3378526,
                "base_fee_burn": "1165572915135208",
                "gas_premium": "100324",
                "gas_fee_cap": "3686864772",
                "over_estimation_burn": "39331788873556",
                "params_params": "",
                "params_method": "",
                "params_txnid": 4,
                "params_json": "",
                "return_json": "{\"Ret\": null, \"Code\": 0, \"Applied\": true}",
                "exit_code": 0
              }
            ]
          },
          {
            "mid": "165282200243",
            "cid": "bafy2bzaceaystqtkjtikswi3m2l4zdh3dp6ilw2dcqyrobchwvfek2rpnoag4",
            "block_epoch": 1652822,
            "block_time": 1647891060,
            "from": "f1ceb34gnsc6qk5dt6n7xg6ycwzasjhbxm3iylkiy",
            "to": "f0121",
            "nonce": 4956,
            "status": "applied",
            "method_name": "Propose",
            "gas_fee": "466949751757631",
            "gas_limit": 3160683,
            "gas_used": 2554547,
            "base_fee_burn": "451912872744536",
            "gas_premium": "100277",
            "gas_fee_cap": "1921481887",
            "over_estimation_burn": "14719935203904",
            "params_params": "",
            "params_method": "Send",
            "params_txnid": 3,
            "params_json": "{\"To\": \"f1ngz5ix5on6ov4sd5epnqlyfvbenr6s76nqz7piy\", \"Value\": \"1000000000000000000000000\", \"Method\": 0, \"Params\": null}",
            "exit_code": 0,
            "approves": [
              {
                "mid": "165282400368",
                "cid": "bafy2bzacecxzraor35ljh2tonzbe6edlehapyzqe3ojejspko5ihwwsyfsiqk",
                "block_epoch": 1652824,
                "block_time": 1647891120,
                "from": "f1meqrx2ijvgrdquybafmlwgszpmc34b3kg3nohvy",
                "to": "f0121",
                "nonce": 1284,
                "method_name": "",
                "gas_fee": "438785989000152",
                "gas_limit": 2588633,
                "gas_used": 2096907,
                "base_fee_burn": "425119319698311",
                "gas_premium": "99780",
                "gas_fee_cap": "1900449022",
                "over_estimation_burn": "13408375501101",
                "params_params": "",
                "params_method": "",
                "params_txnid": 3,
                "params_json": "",
                "return_json": "{\"Ret\": null, \"Code\": 0, \"Applied\": false}",
                "exit_code": 0
              },
              {
                "mid": "165282800267",
                "cid": "bafy2bzacebagm2qy22utz2in7sd672llweila3m5xwq4lh7st4ujuhp7iv5g2",
                "block_epoch": 1652828,
                "block_time": 1647891240,
                "from": "f1ovvm6oilbdsvbw27jhil3pcywrjuwiv5uzagq6i",
                "to": "f0121",
                "nonce": 413,
                "method_name": "",
                "gas_fee": "889799201403875",
                "gas_limit": 4187407,
                "gas_used": 3375926,
                "base_fee_burn": "860348023007260",
                "gas_premium": "100645",
                "gas_fee_cap": "2315410678",
                "over_estimation_burn": "29029736819100",
                "params_params": "",
                "params_method": "",
                "params_txnid": 3,
                "params_json": "",
                "return_json": "{\"Ret\": null, \"Code\": 0, \"Applied\": true}",
                "exit_code": 0
              }
            ]
          },
          {
            "mid": "110900200411",
            "cid": "bafy2bzacedyxj6eobrcv3u3oso7x2q4n3wzpkkmveforgeunx3hb5u65rdc5g",
            "block_epoch": 1109002,
            "block_time": 1631576460,
            "from": "f1ceb34gnsc6qk5dt6n7xg6ycwzasjhbxm3iylkiy",
            "to": "f0121",
            "nonce": 4619,
            "status": "applied",
            "method_name": "Propose",
            "gas_fee": "670490830393896",
            "gas_limit": 3172058,
            "gas_used": 2563647,
            "base_fee_burn": "649022944525416",
            "gas_premium": "99792",
            "gas_fee_cap": "2255517560",
            "over_estimation_burn": "21151339856544",
            "params_params": "",
            "params_method": "Send",
            "params_txnid": 2,
            "params_json": "{\"To\": \"f1ngz5ix5on6ov4sd5epnqlyfvbenr6s76nqz7piy\", \"Value\": \"2000000000000000000000000\", \"Method\": 0, \"Params\": null}",
            "exit_code": 0,
            "approves": [
              {
                "mid": "110901000218",
                "cid": "bafy2bzacebwcpwccz4k7s6a5eza7fwg6vfsk6765tbormgnf2pmlwf7aolv3k",
                "block_epoch": 1109010,
                "block_time": 1631576700,
                "from": "f1ovvm6oilbdsvbw27jhil3pcywrjuwiv5uzagq6i",
                "to": "f0121",
                "nonce": 284,
                "method_name": "",
                "gas_fee": "1044536237070486",
                "gas_limit": 6305038,
                "gas_used": 5070031,
                "base_fee_burn": "1008629655205864",
                "gas_premium": "99577",
                "gas_fee_cap": "2194350446",
                "over_estimation_burn": "35278745095696",
                "params_params": "",
                "params_method": "",
                "params_txnid": 2,
                "params_json": "",
                "return_json": "{\"Ret\": null, \"Code\": 0, \"Applied\": true}",
                "exit_code": 0
              },
              {
                "mid": "110900600308",
                "cid": "bafy2bzacebpybtx3hl4ytkuzeifjwaiqx7teqks2rdgv2wfj3jyjv5toi5his",
                "block_epoch": 1109006,
                "block_time": 1631576580,
                "from": "f1meqrx2ijvgrdquybafmlwgszpmc34b3kg3nohvy",
                "to": "f0121",
                "nonce": 950,
                "method_name": "",
                "gas_fee": "507092254754396",
                "gas_limit": 2687952,
                "gas_used": 2176362,
                "base_fee_burn": "491228701918470",
                "gas_premium": "99473",
                "gas_fee_cap": "2457350601",
                "over_estimation_burn": "15596174186630",
                "params_params": "",
                "params_method": "",
                "params_txnid": 2,
                "params_json": "",
                "return_json": "{\"Ret\": null, \"Code\": 0, \"Applied\": false}",
                "exit_code": 0
              }
            ]
          }
        ]
      }
    });
    },queryParameters: {'actor': 'f0121', 'direction': 'down', 'mid': '', 'limit': 20})
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
  Global.store = store;
  $store.setMultiWallet(
      MultiSignWallet(id: 'f0121', signers: [FilAddr, FilAddr]));
  MultiBloc bloc = MockMultiBloc();

  // var aa = PreferencesManager.getString('host');
  // print(aa);
  var box = MockmultiProposeInstance();
  var mes = CacheMultiMessage();
  var _mockPreferencesManager = MockPreferencesManagerX();
  when(box.values).thenReturn([mes]);
  when(_mockPreferencesManager.getString(any))
      .thenAnswer((realInvocation) => 'apibwwc1FZLnJ80.xyz');
  var box1 = mockMultibox();
  var multi = MultiSignWallet();
  when(box1.values).thenReturn([multi]);
  testWidgets('test multi page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
          initialRoute: multiMainPage,
          getPages: [
            GetPage(
                name: multiMainPage,
                page: () => Provider(
                    create: (_) => bloc..add(getWalletSortedMessagesEvent(MultiTabs.proposal)),
                    child: MultiBlocProvider(
                        providers: [BlocProvider<MultiBloc>.value(value: bloc)],
                        child: MaterialApp(
                          home: MultiMainPage(),
                        )
                    )
                )
            )],
        ));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

}

class FakeSharedPreferencesStore implements SharedPreferencesStorePlatform {
  FakeSharedPreferencesStore(Map<String, Object> data)
      : backend = InMemorySharedPreferencesStore.withData(data);

  final InMemorySharedPreferencesStore backend;
  final List<MethodCall> log = <MethodCall>[];

  @override
  bool get isMock => true;

  @override
  Future<bool> clear() {
    log.add(const MethodCall('clear'));
    return backend.clear();
  }

  @override
  Future<Map<String, Object>> getAll() {
    log.add(const MethodCall('getAll'));
    return backend.getAll();
  }

  @override
  Future<bool> remove(String key) {
    log.add(MethodCall('remove', key));
    return backend.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    log.add(MethodCall('setValue', <dynamic>[valueType, key, value]));
    return backend.setValue(valueType, key, value);
  }
}