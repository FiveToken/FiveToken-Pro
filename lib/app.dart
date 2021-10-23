import 'package:connectivity/connectivity.dart';
import 'package:fil/common/navigation.dart';
import 'package:fil/i10n/localization.dart';
import 'package:fil/index.dart';
import 'package:fil/lang/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './routes/routes.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends StatefulWidget {
  final String initialRoute;
  App(this.initialRoute);
  @override
  State createState() {
    return AppState();
  }
}

class AppState extends State<App> with WidgetsBindingObserver {
  Timer timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDevice();
    migrateAddress();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      deletePushList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void deletePushList() async {
    var now = getSecondSinceEpoch();
    var wal = $store.wal;
    var source = wal.addrWithNet;
    var list = OpenedBox.pushInsance.values.where((mes) {
      if (wal.walletType != 2) {
        return mes.from == $store.wal.addrWithNet;
      } else {
        var list = OpenedBox.minerAddressInstance.values
            .where(
                (addr) => addr.miner == wal.addrWithNet && addr.type == 'owner')
            .toList();
        if (list.isNotEmpty) {
          source = list[0].address;
        }
        return mes.from == source;
      }
    }).where((mes) {
      var t = int.tryParse(mes.time);
      if (t != null && now - t > 30) {
        return true;
      } else {
        return false;
      }
    });
    if (list.isNotEmpty) {
      var nonce = await Global.provider.getNonce(source);
      if (nonce != -1) {
        var now = getSecondSinceEpoch();
        List<String> keys = [];
        list.forEach((mes) {
          var time = int.tryParse(mes.time) ?? 0;
          if (mes.nonce == null || now - time > 3600 * 2 || mes.nonce < nonce) {
            keys.add(mes.cid);
          }
        });
        OpenedBox.pushInsance.deleteAll(keys);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    super.didChangeAppLifecycleState(appLifecycleState);
    if (appLifecycleState == AppLifecycleState.resumed) {
      Global.eventBus.fire(AppStateChangeEvent());
    }
  }

  void migrateAddress() async {
    var list = OpenedBox.addressInsance.values
        .where((wal) => wal.walletType == 1)
        .toList();
    if (list.isNotEmpty) {
      for (var i = 0; i < list.length; i++) {
        var wal = list[i];
        await OpenedBox.addressBookInsance.put(wal.addrWithNet, wal);
      }
      OpenedBox.addressInsance.deleteAll(list.map((wal) => wal.addrWithNet));
    }
  }
  void initDevice() async {
    await initDeviceInfo();
    await listenNetwork();
  }

  Future listenNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool online = connectivityResult != ConnectivityResult.none;
    Global.online = online;
    Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        Global.online = false;
      } else {
        Global.online = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        duration: Duration(seconds: 20),
        dismissOtherOnShow: true,
        child: GetMaterialApp(
            title: "FiveToken Pro",
            getPages: initRoutes(),
            locale: Locale(Global.langCode ?? 'en'),
            translations: Messages(),
            debugShowCheckedModeBanner: false,
            initialRoute: widget.initialRoute,
            theme: ThemeData(
              appBarTheme: AppBarTheme(brightness: Brightness.light),
              primarySwatch: Colors.blue,
            ),
            defaultTransition: Transition.cupertino,
            navigatorObservers: [routeObserver, PushObserver()],
            localizationsDelegates: [
              ChineseCupertinoLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en', 'US'), // English
              const Locale('zh', 'ZH'), // Chinese
              // ... other locales the app supports
            ],
            builder: (BuildContext context, Widget child) {
              return GestureDetector(
                child: RefreshConfiguration(
                    child: child, headerTriggerDistance: 50),
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus &&
                      currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus.unfocus();
                  }
                },
              );
            }));
  }
}
