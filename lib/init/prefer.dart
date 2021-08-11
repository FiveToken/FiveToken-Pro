import 'package:fil/index.dart';

Future<String> initSharedPreferences() async {
  var initialRoute = mainPage;
  var instance = await SharedPreferences.getInstance();
  Global.store = instance;
  Global.registerId = Global.store.getString('registerId') ?? "";
  if (instance.getInt('passWrongCount') == null) {
    instance.setInt('passWrongCount', 0);
  }

  /// If the the app was opened for the first time, English is preferred.
  /// If there is a cached lang code in device, set language to that
  var langCode = instance.getString(StoreKeyLanguage);
  if (langCode == null) {
    var locale = WidgetsBinding.instance.window.locale;
    if (locale.toString().toLowerCase().indexOf('en') >= 0) {
      langCode = 'en';
    } else {
      langCode = 'zh';
    }
    instance.setString(StoreKeyLanguage, 'zh');
  }
  if (langCode != null) {
    Global.langCode = langCode;
  } else {
    Global.langCode = 'en';
  }
  
  /// As the app support two mode, set when it's start
  /// Offline mode: mainly for sign message
  var mode = instance.getBool('runMode');
  if (mode != null) {
    Global.onlineMode = mode;
  } else {
    Global.onlineMode = true;
  }
  var walletstr = instance.getString(StoreKeyActiveWallet);
  var activeAddrStr = instance.getString('activeWalletAddress');
  var activeMultiStr = instance.getString('activeMultiAddress');

  /// Compatible historical version
  /// In the original version, all data store in SharedPreferences as string
  if (walletstr != null || activeAddrStr != null) {
    Wallet wallet;
    if (activeAddrStr != null) {
      wallet = OpenedBox.addressInsance.get(activeAddrStr);
    } else {
      try {
        var w = jsonDecode(walletstr);
        wallet = Wallet(
            address: w['address'],
            label: w['label'],
            ck: w['ck'],
            type: w['type'],
            walletType: w['walletType'],
            readonly: w['readonly'],
            balance: w['balance'],
            owner: w['owner']);
        instance.remove(StoreKeyActiveWallet);
      } catch (e) {
        print(e);
      }
    }
    if (wallet != null) {
      singleStoreController.setWallet(wallet);
      instance.setString('activeWalletAddress', wallet.addr);
    } else {
      initialRoute = initLangPage;
    }
  } else {
    initialRoute = initLangPage;
  }
  /// set current multi-sig wallet
  if (activeMultiStr != null) {
    MultiSignWallet wal = OpenedBox.multiInsance.get(activeMultiStr);
    singleStoreController.setMultiWallet(wal);
  }
  return initialRoute;
}
