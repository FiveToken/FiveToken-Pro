import 'package:event_bus/event_bus.dart';
import 'package:dio/dio.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/models/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

const StoreKeyActiveWallet = "act-wallet";
const StoreKeyLanguage = "language";
const SignSecp = "secp";
const SignBls = "bls";
const SignTypeBls = 2;
const SignTypeSecp = 1;
const String NetPrefix = 'f';

/// store key
class StoreKey {
  /// language
  static String language = 'language';

  /// active wallet
  static String activeWallet = "act-wallet";

  /// active wallet address
  static String activeWalletAddress = "activeWalletAddress";

  /// active multi address
  static String activeMultiAddress = "activeMultiAddress";

  /// register id
  static String registerId = "registerId";

  /// password wrong key
  static String wrongPasswordCount = "wrongPasswordCount";
}

var filscanWeb = Global.netPrefix == 'f'
    ? "https://m.filscan.io"
    : "https://calibration.filscan.io/mobile";

/// global
class Global {
  /// version
  static String version = "v2.2.1";

  /// is release
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  /// store
  static SharedPreferences store;

  /// active wallet
  static Wallet activeWallet;

  /// event bus
  static EventBus eventBus = EventBus();

  /// select wallet type
  static String selectWalletType = '1';

  /// user id
  static String uuid;

  /// online
  static bool online = false;

  /// platform
  static String platform;

  /// os
  static String os;

  /// register id
  static String registerId;

  /// current multi sign wallet
  static MultiSignWallet currrentMultiSignWallet;

  /// net prefix
  static String get netPrefix => NetPrefix;

  /// active wallet address
  static String activeWalletAddress;

  /// language code
  static String langCode; // zh  en
  /// mode
  static String mode; // online offline
  /// cache wallet
  static Wallet cacheWallet;

  /// price
  static double price;

  /// online mode
  static bool onlineMode = false;

  /// default client
  static Dio defaultClient = Dio();

  /// provider
  static FilecoinProvider provider = FilecoinProvider();
}
