import 'package:fil/routes/address.dart';
import 'package:fil/routes/create.dart';
import 'package:fil/routes/init.dart';
import 'package:fil/routes/message.dart';
import 'package:fil/routes/multi.dart';
import 'package:fil/routes/other.dart';
import 'package:fil/routes/pass.dart';
import 'package:fil/routes/routes.dart';
import 'package:fil/routes/setting.dart';
import 'package:fil/routes/sign.dart';
import 'package:fil/routes/transfer.dart';
import 'package:fil/routes/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test generate routes', () {
    var settingList = getSettingRoutes().length;
    var messageList = getMessageRoutes().length;
    var otherList = getOtherRoutes().length;
    var transferList = getTransferRoutes().length;
    var createList = getCreateRoutes().length;
    var multiList = getMultiRoutes().length;
    var initList = getInitRoutes().length;
    var walletList = getWalletRoutes().length;
    var addressList = getAddressBookRoutes().length;
    var signList = getSignRoutes().length;
    var passList = getPassRoutes().length;
    var allList = initRoutes().length;
    expect(
        allList,
        settingList +
            messageList +
            otherList +
            transferList +
            createList +
            multiList +
            initList +
            walletList +
            addressList +
            signList +
            passList);
  });
}
