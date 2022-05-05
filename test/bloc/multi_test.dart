import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/multi/multi_bloc.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MultiBloc', () {
    MultiBloc multiBloc;

    setUp(() {
      multiBloc = MultiBloc();
    });

    blocTest('updateSelectTypeEvent',
        build: () => multiBloc,
        act: (bloc) => bloc.add(updateSelectTypeEvent(MultiTabs.proposal)),
        expect: () => [
              MultiState(
                balance: '0',
                mid: '',
                selectType: MultiTabs.proposal,
                messageList: [],
                enablePullUp: true,
              )
            ]);
  });
}
