import 'package:fil/index.dart';

List<GetPage> getMessageRoutes() {
  var list = <GetPage>[];
  var make = GetPage(name: mesMakePage, page: () => MesMakePage());
  // var makeList = GetPage(name: mesMakeListPage, page: () => MakeListPage());
  var push = GetPage(name: mesPushPage, page: () => MesPushPage());
  // var pushList = GetPage(name: mesPushListPage, page: () => PushListPage());
  var body = GetPage(name: mesBodyPage, page: () => MesBodyPage());
  //var sign = GetPage(name: mesSignPage, page: () => MesSignPage());
  // var signed = GetPage(name: mesSignedPage, page: () => MesSignedPage());
  var deposit = GetPage(name: mesDepositPage, page: () => DepositPage());
  var method = GetPage(name: mesMethodPage, page: () => MethodSelectPage());
  list
    ..add(make)
    // ..add(makeList)
    ..add(push)
    // ..add(pushList)
    ..add(body)
    //..add(sign)
    // ..add(signed)
    ..add(method)
    ..add(deposit);
  return list;
}
