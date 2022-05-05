import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/message/message_bloc.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/models/message.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FilecoinProvider])
void main() {
  group('MessageBloc', () {
    MessageBloc messageBloc;

    setUp(() {
      messageBloc = MessageBloc();
    });

    // blocTest(
    //     'setRadioTypeEvent',
    //     build: ()=> messageBloc,
    //     act: (bloc) => bloc.add(setRadioTypeEvent(RechargeRadio.offLine)),
    //     expect: ()=>  [
    //       MessageState(
    //         controllers: [TextEditingController()],
    //         controllersLength:0,
    //         method:'0',
    //         message: null,
    //         showDisplay: false,
    //         sealType:'8',
    //         radioType:RechargeRadio.offLine,
    //       )
    //     ]
    // );

    SignedMessage message = null;

    blocTest(
      'setSealTypeEvent',
      build: () => messageBloc,
      act: (bloc) => bloc.add(setSealTypeEvent('8')),
    );

    blocTest(
      'setShowDisplayEvent',
      build: () => messageBloc,
      act: (bloc) => bloc.add(setShowDisplayEvent(false)),
    );

    blocTest(
      'removeControllersEvent',
      build: () => messageBloc,
      act: (bloc) => bloc.add(removeControllersEvent(0)),
    );

    blocTest(
      'setControllersEvent',
      build: () => messageBloc,
      act: (bloc) => bloc.add(setControllersEvent()),
    );

    blocTest(
      'setMessageEvent',
      build: () => messageBloc,
      act: (bloc) => bloc.add(setMessageEvent(message)),
    );
  });
}
