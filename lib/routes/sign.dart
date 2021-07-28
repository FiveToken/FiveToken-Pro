import 'package:fil/index.dart';

List<GetPage> getSignRoutes() {
  var list = <GetPage>[];
  var sign = GetPage(name: signIndexPage, page: () => SignIndexPage());
  list..add(sign);
  return list;
}
