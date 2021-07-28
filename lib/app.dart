import 'package:connectivity/connectivity.dart';
import 'package:fil/common/navigation.dart';
import 'package:fil/i10n/localization.dart';
import 'package:fil/index.dart';
import 'package:fil/lang/index.dart';
import 'package:fil/pages/main/messageList.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './routes/routes.dart';
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class AppStateChangeEvent {}

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    freshList();
    initDevice();
    migrateAddress();
  }

  void freshList() {
    var invalidList = OpenedBox.messageInsance.values.where((mes) {
      var invalidMethod = !ValidMethods.contains(mes.methodName ?? '');
      if (mes.blockTime != null) {
        return invalidMethod ||
            getSecondSinceEpoch() - mes.blockTime > 3600 * 24 * 30;
      } else {
        return invalidMethod;
      }
    }).map((mes) => mes.signedCid);
    OpenedBox.messageInsance.deleteAll(invalidList);
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