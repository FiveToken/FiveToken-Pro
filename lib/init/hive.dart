import 'dart:convert';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/host.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/models/nonce.dart';
import 'package:fil/models/nonce_unit.dart';
import 'package:fil/models/wallet.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const messageBox = 'message';
const addressBox = 'address';
const signedMessageBox = 'signedMessage';
const nonceBox = 'nonceBox';
const nonceUnitBox = 'nonceUnitBox';
const monitorBox = 'monitorAddressBox';
const unsignedMessageBox = 'unsignedMessageBox';
const pushMessageBox = 'pushMessageBox';
const minerDetailBox = 'minerDetailBox';
const multiMessageBox = 'multiSigMessageBox';
const multiWalletBox = 'multiWalletBox';
const gasBox = 'gasBox';
const addressBookBox = 'addressBook';
const minerMetaBox = 'minerMetaBox';
const minerStatisticBox = 'minerStatisticBox';
const multiProposeBox = 'multiProposeBox';
const minerAddressBox = 'minerAddressBox';
const multiApproveBox = 'multiApproveBox';
const minerBalanceBox = '';
const hostBox = 'hostBox';

List<int> encryptionKey;

/// init hive db
Future initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SignedMessageAdapter());
  Hive.registerAdapter(TMessageAdapter());
  Hive.registerAdapter(SignatureAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(StoreMessageAdapter());
  Hive.registerAdapter(NonceAdapter());
  Hive.registerAdapter(NonceUnitAdapter());
  Hive.registerAdapter(StoreUnsignedMessageAdapter());
  Hive.registerAdapter(StoreSignedMessageAdapter());
  Hive.registerAdapter(MinerAddressAdapter());
  Hive.registerAdapter(MinerMetaAdapter());
  Hive.registerAdapter(MinerHistoricalStatsAdapter());
  Hive.registerAdapter(MultiSignWalletAdapter());
  Hive.registerAdapter(StoreMultiMessageAdapter());
  Hive.registerAdapter(CacheGasAdapter());
  Hive.registerAdapter(CacheMultiMessageAdapter());
  Hive.registerAdapter(MultiApproveMessageAdapter());
  Hive.registerAdapter(MinerSelfBalanceAdapter());

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  var containsEncryptionKey = await secureStorage.read(key: 'key');
  if (containsEncryptionKey == null || containsEncryptionKey == '') {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  }
  encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));

  await OpenedBox.initBox();
}

class OpenedBox {
  /// box to store all local messages
  static Box<StoreMessage> messageInsance;

  /// box to store all wallet
  static Box<Wallet> addressInsance;

  /// box to store all address in address book
  static Box<Wallet> addressBookInsance;

  /// box to store all signed messages
  static Box<SignedMessage> signedInstance;

  /// box to store all used nonce
  static Box<Nonce> nonceInsance;

  /// box to store all used nonceUnit
  static Box<NonceUnit> nonceUnitInstance;

  /// box to store all unsigned messages
  static Box<StoreUnsignedMessage> unsignedInsance;

  /// box to store all pushed messages
  static Box<StoreSignedMessage> pushInsance;

  /// box to store all multi-sig messages
  static Box<StoreMultiMessage> multiMesInsance;

  /// box to store all multi-sig wallet
  static Box<MultiSignWallet> multiInsance;

  /// box to store used gas
  static Box<CacheGas> gasInsance;

  /// box to store miner meta info
  static Box<MinerMeta> minerMetaInstance;

  /// box to store miner statistic info
  static Box<MinerHistoricalStats> minerStatisticInstance;

  /// box to store miner statistic info
  static Box<CacheMultiMessage> multiProposeInstance;

  /// box to store miner related address
  static Box<MinerAddress> minerAddressInstance;

  /// box to store multi approves
  static Box<MultiApproveMessage> multiApproveInstance;

  /// box to store miner balance
  static Box<MinerSelfBalance> minerBalanceInstance;

  static Box<Host> hostInstance;

  static Future initBox() async {
    messageInsance = await Hive.openBox<StoreMessage>(messageBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    addressInsance = await Hive.openBox<Wallet>(addressBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    addressBookInsance = await Hive.openBox<Wallet>(addressBookBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    signedInstance = await Hive.openBox<SignedMessage>(signedMessageBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    nonceInsance = await Hive.openBox<Nonce>(nonceBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    nonceUnitInstance = await Hive.openBox<NonceUnit>(nonceUnitBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    unsignedInsance = await Hive.openBox<StoreUnsignedMessage>(
        unsignedMessageBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    pushInsance = await Hive.openBox<StoreSignedMessage>(pushMessageBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    multiMesInsance = await Hive.openBox<StoreMultiMessage>(multiMessageBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    multiInsance = await Hive.openBox<MultiSignWallet>(multiWalletBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    gasInsance = await Hive.openBox<CacheGas>(gasBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    minerMetaInstance = await Hive.openBox<MinerMeta>(minerMetaBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    minerStatisticInstance = await Hive.openBox<MinerHistoricalStats>(
        minerStatisticBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    multiProposeInstance = await Hive.openBox<CacheMultiMessage>(
        multiProposeBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    minerAddressInstance = await Hive.openBox<MinerAddress>(minerAddressBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    multiApproveInstance = await Hive.openBox<MultiApproveMessage>(
        multiApproveBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    minerBalanceInstance = await Hive.openBox<MinerSelfBalance>(minerBalanceBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
    hostInstance = await Hive.openBox<Host>(hostBox,
        encryptionCipher: HiveAesCipher(encryptionKey));
  }
}
