import 'dart:io';
import 'package:fil/store/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fil/data/preferences_manager.dart';
import 'app.dart';
import 'chain/provider.dart';
import 'init/hive.dart';
import 'init/prefer.dart';

void main() async {
  Get.put(StoreController());
  await initHive();
  await PreferencesManager.init();
  var initialRoute = await initSharedPreferences();
  await fetchPing();
  runApp(App(initialRoute));
  SystemUiOverlayStyle style =
      SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light);
  SystemChrome.setSystemUIOverlayStyle(style);
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
