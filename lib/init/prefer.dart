import 'dart:convert';
import 'package:fil/common/global.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hive.dart';

Future<String> initSharedPreferences() async {
  var initialRoute = mainPage;
  var instance = await SharedPreferences.getInstance();
  Global.store = instance;
  Global.registerId = Global.store.getString(StoreKey.registerId) ?? "";
  if (instance.getInt(StoreKey.wrongPasswordCount) == null) {
    instance.setInt(StoreKey.wrongPasswordCount, 0);
  }

  /// If the the app was opened for the first time, English is preferred.
  /// If there is a cached lang code in device, set language to that
  var langCode = instance.getString(StoreKeyLanguage);
  if (langCode == null) {
    var locale = WidgetsBinding.instance.window.locale;
    var isEn = locale.toString().toLowerCase().indexOf('en') >= 0;
    langCode = isEn ? 'en' : 'zh';
    instance.setString(StoreKeyLanguage, 'zh');
  }

  Global.langCode = langCode != null ? langCode : 'en';

  /// As the app support two mode, set when it's start
  /// Offline mode: mainly for sign message
  var mode = instance.getBool('runMode');
  Global.onlineMode = mode != null ? mode : true;
  var activeWallet = instance.getString(StoreKey.activeWallet);
  var activeAddress = instance.getString(StoreKey.activeWalletAddress);
  var activeMultiAddress = instance.getString(StoreKey.activeMultiAddress);

  /// Compatible historical version
  /// In the original version, all data store in SharedPreferences as string
  if (activeWallet != null || activeAddress != null) {
    Wallet wallet;
    if (activeAddress != null) {
      wallet = OpenedBox.addressInsance.get(activeAddress);
    } else {
      try {
        var decodeWallet = jsonDecode(activeWallet);
        wallet = Wallet(
            address: decodeWallet['address'] as String,
            label: decodeWallet['label'] as String,
            ck: decodeWallet['ck'] as String,
            type: decodeWallet['type'] as String,
            walletType: decodeWallet['walletType'] as int,
            readonly: decodeWallet['readonly'] as int,
            balance: decodeWallet['balance'] as String,
            owner: decodeWallet['owner'] as String);
        instance.remove(StoreKey.activeWallet);
      } catch (e) {
        print(e);
      }
    }
    if (wallet != null) {
      $store.setWallet(wallet);
      instance.setString(StoreKey.activeWalletAddress, wallet.addr);
    } else {
      initialRoute = initLangPage;
    }
  } else {
    initialRoute = initLangPage;
  }

  /// set current multi-sig wallet
  if (activeMultiAddress != null) {
    MultiSignWallet wal = OpenedBox.multiInsance.get(activeMultiAddress);
    $store.setMultiWallet(wal);
  }
  return initialRoute;
}
