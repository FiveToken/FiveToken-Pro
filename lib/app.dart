import 'package:connectivity/connectivity.dart';
import 'package:fil/common/navigation.dart';
import 'package:fil/i10n/localization.dart';
import 'package:fil/index.dart';
import 'package:fil/lang/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './routes/routes.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

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
  AppState() {
    var dio = Dio();
    dio.options.baseUrl = ServerAddress.use;
    dio.options.connectTimeout = 20000;
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      options.validateStatus = (status) {
        return status < 1000;
      };

      return options;
    }, onResponse: (Response response) async {
      return response;
    }));
    Global.dio = dio;
  }
  Timer timer;
  final JPush jpush = new JPush();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    freshList();
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

  void freshList() {
    var invalidList = OpenedBox.messageInsance.values.where((mes) {
      var invalidMethod =
          !FilecoinMethod.validMethods.contains(mes.methodName ?? '');
      if (mes.blockTime != null) {
        return invalidMethod ||
            getSecondSinceEpoch() - mes.blockTime > 3600 * 24 * 30;
      } else {
        return invalidMethod;
      }
    }).map((mes) => mes.signedCid);
    OpenedBox.messageInsance.deleteAll(invalidList);
  }

  void deletePushList() async {
    var wal = $store.wal;
    var source = wal.addrWithNet;
    var list = OpenedBox.pushInsance.values.where((mes) {
      if (wal.walletType != 2) {
        return mes.from == $store.wal.addrWithNet;
      } else {
        var list = OpenedBox.monitorInsance.values
            .where(
                (addr) => addr.miner == wal.addrWithNet && addr.type == 'owner')
            .toList();
        if (list.isNotEmpty) {
          source = list[0].cid;
        }
        return mes.from == source;
      }
    });
    if (list.isNotEmpty) {
      var nonce = await getNonce(source);
      if (nonce != -1) {
        var now = getSecondSinceEpoch();
        List<String> keys = [];
        list.forEach((mes) {
          var time = int.tryParse(mes.time) ?? 0;
          if (mes.nonce < nonce || now - time > 3600 * 2) {
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

  Future<void> initPlatformState() async {
    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
            print("flutter onReceiveNotification: $message");
          },
          onOpenNotification: (Map<String, dynamic> message) async {},
          onReceiveMessage: (Map<String, dynamic> message) async {
            print("flutter onReceiveMessage: $message");
          },
          onReceiveNotificationAuthorization:
              (Map<String, dynamic> message) async {
            print("flutter onReceiveNotificationAuthorization: $message");
          });
    } on PlatformException {
      print('error');
    }

    jpush.setup(
      appKey: "ca9f7f0f57a10c8a7637bcbb",
      channel: "developer-default",
      production: Global.isRelease,
      debug: !Global.isRelease,
    );
    // jpush.applyPushAuthority(
    //     new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    var rid = Global.store.getString('registerId');
    if (rid == null) {
      jpush.getRegistrationID().then((id) {
        if (id != '') {
          Global.store.setString('registerId', id);
          registerJpushId(id);
        }
      });
    }
  }

  void initDevice() async {
    await initDeviceInfo();
    await listenNetwork();
    initPlatformState();
    registerDevice();
    // if (Global.store.getString('register') == null) {
    //   await registerDevice();
    //   Global.store.setString('register', '1');
    // }
    pushAction(page: '', type: 'open');
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
