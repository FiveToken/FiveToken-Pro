import 'package:fil/index.dart';

List<GetPage> getInitRoutes() {
  var list = <GetPage>[];
  var lang = GetPage(
      name: initLangPage,
      page: () => SelectLangPage(),
      transition: Transition.fadeIn);
  var wallet = GetPage(name: initWalletPage, page: () => WalletInitPage());
  var mode=GetPage(name: initModePage, page: ()=>WalletModePage());
  list..add(wallet)..add(lang)..add(mode);
  return list;
}
