import 'package:fil/chain/constant.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var idAddressMethods = [ 'Exec', 'CreateMiner'];
  var validMethods = [
    'Send',
    'Exec',
    'WithdrawBalance',
    'CreateMiner',
    'ConfirmUpdateWorkerKey',
    'ChangeWorkerAddress',
    'ChangeOwnerAddress'];
  TMessage message0 = TMessage(method:0, to: FilecoinAccount.f01);
  TMessage message1 = TMessage(method:1, to: FilecoinAccount.f01);
  TMessage message = TMessage(method:2, to: FilecoinAccount.f01);
  TMessage message3 = TMessage(method:3, to: FilecoinAccount.f01);
  TMessage message16 = TMessage(method:16, to: FilecoinAccount.f01);
  TMessage message21 = TMessage(method:21, to: FilecoinAccount.f01);
  TMessage message23 = TMessage(method:23, to: FilecoinAccount.f01);
  testWidgets("test chain constant", (tester) async {
    expect(FilecoinAccount.f02, Global.netPrefix + '02');
    expect(FilecoinAccount.f04, Global.netPrefix + '04');
    expect(FilecoinAccount.f099, Global.netPrefix + '099');

    expect(FilecoinMethod.transfer, 'transfer');
    expect(FilecoinMethod.approve, 'Approve');
    expect(FilecoinMethod.propose, 'Propose');
    expect(FilecoinMethod.validMethods, validMethods);
    expect(FilecoinMethod.idAddressMethods, idAddressMethods);

    expect(FilecoinMethod.getMethodNameByMessage(message0), FilecoinMethod.send);
    expect(FilecoinMethod.getMethodNameByMessage(message), FilecoinMethod.exec);
    expect(FilecoinMethod.getMethodNameByMessage(message1), FilecoinMethod.send);
    expect(FilecoinMethod.getMethodNameByMessage(message3), FilecoinMethod.changeOwner);
    expect(FilecoinMethod.getMethodNameByMessage(message16), FilecoinMethod.withdraw);
    expect(FilecoinMethod.getMethodNameByMessage(message21), FilecoinMethod.confirmUpdateWorkerKey);
    expect(FilecoinMethod.getMethodNameByMessage(message23), FilecoinMethod.changeWorker);
  });
}