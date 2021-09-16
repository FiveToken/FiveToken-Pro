import 'package:fil/index.dart';

List<GetPage> getOtherRoutes() {
  var list = <GetPage>[];
  var scan = GetPage(name: scanPage, page: () => ScanPage());
  var error = GetPage(name: errorPage, page: () => ErrorPage());
  var setting = GetPage(name: setPage, page: () => SetPage());
  var lang = GetPage(name: langPage, page: () => LangPage());
  var dis = GetPage(name: discoveryPage, page: () => DiscoveryPage());
  var notification = GetPage(name: notificationPage, page: () => NotificationPage());
  list
    ..add(scan)
    ..add(error)
    ..add(setting)
    ..add(lang)
    ..add(notification)
    ..add(dis);
  return list;
}
