import 'package:fil/index.dart';

List<GetPage> getOtherRoutes() {
  var list = <GetPage>[];
  var web = GetPage(name: webviewPage, page: () => WebviewPage());
  var scan = GetPage(name: scanPage, page: () => ScanPage());
  var error = GetPage(name: errorPage, page: () => ErrorPage());
  var setting = GetPage(name: setPage, page: () => SetPage());
  var lang = GetPage(name: langPage, page: () => LangPage());
  var dis = GetPage(name: discoveryPage, page: () => DiscoveryPage());
  list
    ..add(web)
    ..add(scan)
    ..add(error)
    ..add(setting)
    ..add(lang)
    ..add(dis);
  return list;
}
