import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/proposal/proposal_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProposalBloc', () {
    ProposalBloc proposalBloc;

    setUp(() {
      proposalBloc = ProposalBloc();
    });

    // blocTest(
    //     'updateSelectTypeEvent',
    //     build: ()=> proposalBloc,
    //     act: (bloc) => bloc.add(addControllersEvent()),
    //     expect: ()=>  [
    //       ProposalState(
    //         controllers: [],
    //         controllersLength:0,
    //         methodId:'',
    //       )
    //     ]
    // );

    blocTest(
      'removeControllersEvent',
      build: () => proposalBloc,
      act: (bloc) => bloc.add(removeControllersEvent(0)),
    );

    blocTest(
      'setControllersEvent',
      build: () => proposalBloc,
      act: (bloc) => bloc.add(setControllersEvent()),
    );
  });
}
