import 'package:event_bus/event_bus.dart';
import 'package:fil/index.dart';
import 'package:dio/dio.dart';

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
class Global {
  static String version = "v2.1.0";

  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  static SharedPreferences store;

  static Wallet activeWallet;


  static Dio dio;
  static EventBus eventBus = EventBus();

  static Map<String, dynamic> info = {};

  static String selectWalletType = '1';
  static String uuid;
  static bool online = false;
  static String platform;
  static String os;
  static String registerId;
  static MultiSignWallet currrentMultiSignWallet;
  static String get netPrefix => NetPrefix;
  static String activeWalletAddress;
  static String langCode;
  static String mode;
  static Wallet cacheWallet;
  static FilPrice price;
  static bool onlineMode=false;
}
