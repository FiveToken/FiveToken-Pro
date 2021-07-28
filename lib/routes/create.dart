import 'package:fil/index.dart';
import 'package:fil/pages/create/entrance.dart';

List<GetPage> getCreateRoutes() {
  var list = <GetPage>[];
  var mne = GetPage(name: mnePage, page: () => MneCreatePage());
  var mneCheck = GetPage(name: mneCheckPage, page: () => MneCheckPage());
  var importPrivate =
      GetPage(name: importPrivateKeyPage, page: () => ImportPrivateKeyPage());
  var importMne = GetPage(name: importMnePage, page: () => ImportMnePage());
  var readonly = GetPage(name: readonlyPage, page: () => ReadonlyPage());
  var miner = GetPage(name: minerPage, page: () => MinerPage());
  var warn = GetPage(name: createWarnPage, page: () => CreateWarnPage());
  var entrance = GetPage(name: createEntrancePage, page: () => CreateEntrancePage());
  list
    ..add(mne)
    ..add(mneCheck)
    ..add(importPrivate)
    ..add(importMne)
    ..add(miner)
    ..add(readonly)
    ..add(entrance)
    ..add(warn);
  return list;
}
