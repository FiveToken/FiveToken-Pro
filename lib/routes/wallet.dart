import 'package:fil/index.dart';

List<GetPage> getWalletRoutes() {
  var list = <GetPage>[];
  var manage = GetPage(name: walletMangePage, page: () => WalletManagePage());
  var mne = GetPage(name: walletMnePage, page: () => WalletMnePage());
  var private =
      GetPage(name: walletPrivatekey, page: () => WalletPrivatekeyPage());
  var code = GetPage(name: walletCodePage, page: () => WalletCodePage());
  var select = GetPage(name: walletSelectPage, page: () => WalletListPage());
  list..add(manage)..add(mne)..add(private)..add(code)..add(select);
  return list;
}
