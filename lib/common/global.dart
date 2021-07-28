import 'package:event_bus/event_bus.dart';
import 'package:fil/index.dart';
import 'package:dio/dio.dart';
import 'package:fil/i10n/translation.dart';

const StoreKeyHash = "hash";
const StoreKeyActiveWallet = "act-wallet";
const StoreKeyLanguage = "language";

const InfoKeyWebUrl = "webUrl";
const InfoKeyWebTitle = "webTitle";

const SignSecp = "secp";
const SignBls = "bls";
const SignTypeBls = 2;
const SignTypeSecp = 1;
const String NetPrefix = 'f';
// webview useragent
const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36 ForceWallet/0.1.1';

class Global {
  static String version = "v2.0.0";
  // kv store

  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  static SharedPreferences store;

  static Wallet activeWallet;


  static Dio dio;

  static Translation t = Translation();

  static EventBus eventBus = EventBus();

  static Map<String, dynamic> info = {};

  static DateTime latestAuthTime;
  static Net net;
  static List<Net> netList = [];
  static String selectWalletType = '1';
  static String uuid;
  static bool online = false;
  static String platform;
  static String os;
  static String registerId;
  static bool deviceLock = false;
  static bool gestureSet = false;
  static MultiSignWallet currrentMultiSignWallet;
  static String get netPrefix => NetPrefix;
  static bool needMigrate = false;
  static String activeWalletAddress;
  static String deviceCheckMessage;
  static String langCode;
  static String mode;
  static Wallet cacheWallet;
  static FilPrice price;
  static bool onlineMode=false;
}
