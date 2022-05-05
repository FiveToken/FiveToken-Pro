import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/detail/detail_bloc.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'detail_test.mocks.dart';

@GenerateMocks([FilecoinProvider])
void main() {
  group('detailBloc', () {
    DetailBloc detailBloc;
    final mockFilecoinProvider = MockFilecoinProvider();
    final StoreMessage message = StoreMessage.fromJson({
      'from': '',
      'to': '',
      'nonce': 0,
      'height': 0,
      'value': '',
      'pending': 1,
      'methodName': '',
      'allGasFee': '',
      'signedCid': '',
    });
    setUp(() {
      detailBloc = DetailBloc();
    });

    blocTest('getMessageDetailEvent',
        build: () => detailBloc,
        act: (bloc) => bloc.add(getMessageDetailEvent(message)),
        expect: () => [
              DetailState(
                  from: '',
                  to: '',
                  nonce: 0,
                  height: 0,
                  value: '',
                  pending: 1,
                  methodName: '',
                  allGasFee: '0',
                  signedCid: '',
                  args: {},
                  returns: {})
            ]);
  });
}
