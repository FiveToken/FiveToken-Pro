import 'package:fil/index.dart';
import 'package:fil/pages/other/webview.dart';

List<GetPage> getOtherRoutes() {
  var list = <GetPage>[];
  var scan = GetPage(name: scanPage, page: () => ScanPage());
  var setting = GetPage(name: setPage, page: () => SetPage());
  var lang = GetPage(name: langPage, page: () => LangPage());
  var dis = GetPage(name: discoveryPage, page: () => DiscoveryPage());
  var webview = GetPage(
      name: webviewPage,
      page: () => WebviewPage(),
      fullscreenDialog: true,
      transition: Transition.downToUp);
  list
    ..add(scan)
    ..add(setting)
    ..add(lang)
    ..add(dis)
    ..add(webview);
  return list;
}
