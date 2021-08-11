import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fil/index.dart';

const messageBox = 'message';
const addressBox = 'address';
const signedMessageBox = 'signedMessage';
const nonceBox = 'nonceBox';
const monitorBox = 'monitorAddressBox';
const unsignedMessageBox = 'unsignedMessageBox';
const pushMessageBox = 'pushMessageBox';
const minerDetailBox = 'minerDetailBox';
const multiMessageBox = 'multiSigMessageBox';
const multiWalletBox = 'multiWalletBox';
const gasBox = 'gasBox';
const addressBookBox = 'addressBook';

/// init hive db
Future initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SignedMessageAdapter());
  Hive.registerAdapter(TMessageAdapter());
  Hive.registerAdapter(SignatureAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(StoreMessageAdapter());
  Hive.registerAdapter(NonceAdapter());
  Hive.registerAdapter(MonitorAddressAdapter());
  Hive.registerAdapter(StoreUnsignedMessageAdapter());
  Hive.registerAdapter(StoreSignedMessageAdapter());
  Hive.registerAdapter(MinerAddressAdapter());
  Hive.registerAdapter(MinerMetaAdapter());
  Hive.registerAdapter(MinerHistoricalStatsAdapter());
  Hive.registerAdapter(MinerStatsAdapter());
  Hive.registerAdapter(MinerInfoAdapter());
  Hive.registerAdapter(MultiSignWalletAdapter());
  Hive.registerAdapter(StoreMultiMessageAdapter());
  Hive.registerAdapter(CacheGasAdapter());
  await Hive.openBox<StoreMessage>(messageBox);
  await Hive.openBox<Wallet>(addressBox);
  await Hive.openBox<SignedMessage>(signedMessageBox);
  await Hive.openBox<Nonce>(nonceBox);
  await Hive.openBox<MonitorAddress>(monitorBox);
  await Hive.openBox<StoreUnsignedMessage>(unsignedMessageBox);
  await Hive.openBox<StoreSignedMessage>(pushMessageBox);
  await Hive.openBox<MinerInfo>(minerDetailBox);
  await Hive.openBox<StoreMultiMessage>(multiMessageBox);
  await Hive.openBox<MultiSignWallet>(multiWalletBox);
  await Hive.openBox<Wallet>(addressBookBox);
  await Hive.openBox<CacheGas>(gasBox);
  //OpenedBox.addressInsance.deleteFromDisk();
  //OpenedBox.multiMesInsance.deleteFromDisk();
  // OpenedBox.multiInsance.deleteFromDisk();
}

class OpenedBox {
  /// box to store all local messages
  static Box<StoreMessage> get messageInsance {
    return Hive.box<StoreMessage>(messageBox);
  }

  /// box to store all wallet
  static Box<Wallet> get addressInsance {
    return Hive.box<Wallet>(addressBox);
  }

  /// box to store all address in address book
  static Box<Wallet> get addressBookInsance {
    return Hive.box<Wallet>(addressBookBox);
  }

  /// box to store all signed messages
  static Box<SignedMessage> get signedInstance {
    return Hive.box<SignedMessage>(signedMessageBox);
  }

  /// box to store all used nonce
  static Box<Nonce> get nonceInsance {
    return Hive.box<Nonce>(nonceBox);
  }

  /// box to store workers or controllers of a miner
  static Box<MonitorAddress> get monitorInsance {
    return Hive.box<MonitorAddress>(monitorBox);
  }

  /// box to store all unsigned messages
  static Box<StoreUnsignedMessage> get unsignedInsance {
    return Hive.box<StoreUnsignedMessage>(unsignedMessageBox);
  }

  /// box to store all pushed messages
  static Box<StoreSignedMessage> get pushInsance {
    return Hive.box<StoreSignedMessage>(pushMessageBox);
  }

  /// box to store info of miner
  static Box<MinerInfo> get minerInsance {
    return Hive.box<MinerInfo>(minerDetailBox);
  }

  /// box to store all multi-sig messages
  static Box<StoreMultiMessage> get multiMesInsance {
    return Hive.box<StoreMultiMessage>(multiMessageBox);
  }

  /// box to store all multi-sig wallet
  static Box<MultiSignWallet> get multiInsance {
    return Hive.box<MultiSignWallet>(multiWalletBox);
  }

  /// box to store used gas
  static Box<CacheGas> get gasInsance {
    return Hive.box<CacheGas>(gasBox);
  }
}
