import 'package:fil/index.dart';

List<GetPage> getPassRoutes() {
  var list = <GetPage>[];
  var init = GetPage(name: passwordSetPage, page: () => PassInitPage());
  var reset = GetPage(name: passwordResetPage, page: () => PassResetPage());
  list..add(init)..add(reset);
  return list;
}
