import 'package:fil/index.dart';

List<GetPage> getSettingRoutes() {
  var list = <GetPage>[];
  var about = GetPage(name: aboutPage, page: () => AboutPage());
  list..add(about);
  return list;
}
