import 'package:fil/index.dart';
import './setting.dart';
import './create.dart';
import './message.dart';
import './other.dart';
import 'transfer.dart';
//import './discovery.dart';
import './multi.dart';
import './init.dart';
import './pass.dart';
import './wallet.dart';
import './address.dart';
import './sign.dart';

class GetTranstionPage {}

List<GetPage> list = [];
List<GetPage> initRoutes() {
  var list = <GetPage>[];
  var main = GetPage(name: mainPage, page: () => MainPage());
  list
    ..add(main)
    ..addAll(getSettingRoutes())
    ..addAll(getMessageRoutes())
    ..addAll(getOtherRoutes())
    ..addAll(getTransferRoutes())
    ..addAll(getCreateRoutes())
    ..addAll(getMultiRoutes())
    ..addAll(getInitRoutes())
    //..addAll(getDiscoveryRoute())
    ..addAll(getWalletRoutes())
    ..addAll(getAddressBookRoutes())
    ..addAll(getSignRoutes())
    ..addAll(getPassRoutes());
  return list;
}
