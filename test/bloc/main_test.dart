import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:fil/data/preferences_manager.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'main_test.mocks.dart';

@GenerateMocks([FilecoinProvider, PreferencesManagerX])
void main() {
  group('MainBloc', () {
    var _mockFilecoinProvider = MockFilecoinProvider();
    var _mockPreferencesManager = MockPreferencesManagerX();
    var host = 'https://api.fivetoken.io/api/7om8n3ri4v23pjjfs4ozctlb';

    when(_mockPreferencesManager.getString(any))
        .thenAnswer((realInvocation) => host);

    MainBloc mainBloc;
    setUp(() {
      when(_mockFilecoinProvider.getFilPrice())
          .thenAnswer((realInvocation) => Future.value(1.0));

      mainBloc = MainBloc();
    });

    blocTest(
      'setSelectTypeEvent',
      build: () => mainBloc,
      act: (bloc) => bloc.add(setSelectTypeEvent(WalletType.all)),
      // expect: ()=>  [
      //   MainState(
      //     price: 0,
      //     selectType:WalletType.all,
      //     nodeList:[],
      //     meta: MinerMeta(),
      //     transferType:TransferType.all,
      //     messageList:[],
      //     enablePullUp:true,
      //     balance:'0',
      //     mid:'',
      //     stats:MinerHistoricalStats(),
      //     info:MinerSelfBalance(),
      //   )
      // ]
    );
  });
}
