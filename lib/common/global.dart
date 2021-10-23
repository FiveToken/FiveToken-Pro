import 'package:event_bus/event_bus.dart';
import 'package:fil/index.dart';
import 'package:dio/dio.dart';

const StoreKeyActiveWallet = "act-wallet";
const StoreKeyLanguage = "language";
const SignSecp = "secp";
const SignBls = "bls";
const SignTypeBls = 2;
const SignTypeSecp = 1;
const String NetPrefix = 'f';


var filscanWeb = Global.netPrefix == 'f'
    ? "https://m.filscan.io"
    : "https://calibration.filscan.io/mobile";
class Global {
  static String version = "v2.2.0";

  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  static SharedPreferences store;

  static Wallet activeWallet;
  static EventBus eventBus = EventBus();
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
  static bool onlineMode = false;
  static Dio defaultClient = Dio();
  static FilecoinProvider provider = FilecoinProvider();
}
