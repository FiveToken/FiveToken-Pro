
import 'package:fil/bloc/proposal/proposal_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/data/preferences_manager.dart';
import 'package:fil/pages/multi/proposal.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/main_test.mocks.dart';
import '../../provider.dart';
class MockProposalBloc extends Mock implements ProposalBloc{}

@GenerateMocks([
  PreferencesManagerX
])

void main() {
  final _preferencesManager =  MockPreferencesManagerX();
  PreferencesManagerX().injection(_preferencesManager);
  Get.put(StoreController());
  ProposalBloc bloc = MockProposalBloc();
  var host = 'https://api.fivetoken.io/api/7om8n3ri4v23pjjfs4ozctlb';
  when(
      PreferencesManagerX().getString(any)
  ).thenAnswer(
          (realInvocation) => host
  );
  var adapter = mockProvider();
  testWidgets('test render multi proposal page', (tester) async {
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: multiProposalPage,
        getPages: [
          GetPage(name: multiProposalPage, page: ()=> Provider(
            create: (_) => bloc..add(setControllersEvent()),
            child: MultiBlocProvider(
                providers: [BlocProvider<ProposalBloc>.value(value: bloc)],
                child: MaterialApp(
                  home:  MultiProposalPage(),
                )
            )
          ))
        ],
      ));
      await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}