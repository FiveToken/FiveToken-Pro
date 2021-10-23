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
const minerMetaBox = 'minerMetaBox';
const minerStatisticBox = 'minerStatisticBox';
const multiProposeBox = 'multiProposeBox';
const minerAddressBox = 'minerAddressBox';
const multiApproveBox = 'multiApproveBox';
const minerBalanceBox = '';

/// init hive db
Future initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SignedMessageAdapter());
  Hive.registerAdapter(TMessageAdapter());
  Hive.registerAdapter(SignatureAdapter());
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(StoreMessageAdapter());
  Hive.registerAdapter(NonceAdapter());
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
  await Hive.openBox<StoreMessage>(messageBox);
  await Hive.openBox<Wallet>(addressBox);
  await Hive.openBox<SignedMessage>(signedMessageBox);
  await Hive.openBox<Nonce>(nonceBox);
  await Hive.openBox<StoreUnsignedMessage>(unsignedMessageBox);
  await Hive.openBox<StoreSignedMessage>(pushMessageBox);
  await Hive.openBox<StoreMultiMessage>(multiMessageBox);
  await Hive.openBox<MultiSignWallet>(multiWalletBox);
  await Hive.openBox<Wallet>(addressBookBox);
  await Hive.openBox<CacheGas>(gasBox);
  await Hive.openBox<MinerMeta>(minerMetaBox);
  await Hive.openBox<MinerHistoricalStats>(minerStatisticBox);
  await Hive.openBox<CacheMultiMessage>(multiProposeBox);
  await Hive.openBox<MinerAddress>(minerAddressBox);
  await Hive.openBox<MultiApproveMessage>(multiApproveBox);
  await Hive.openBox<MinerSelfBalance>(minerBalanceBox);
  OpenedBox.initBox();
  // OpenedBox.addressInsance.deleteFromDisk();
  // OpenedBox.multiMesInsance.deleteFromDisk();
  // OpenedBox.multiInsance.deleteFromDisk();
  // OpenedBox.messageInsance.deleteFromDisk();
  // OpenedBox.minerAddressInstance.deleteFromDisk();
  // OpenedBox.multiProposeInstance.deleteFromDisk();
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
  static void initBox() {
    messageInsance = Hive.box<StoreMessage>(messageBox);
    addressInsance = Hive.box<Wallet>(addressBox);
    addressBookInsance = Hive.box<Wallet>(addressBookBox);
    signedInstance = Hive.box<SignedMessage>(signedMessageBox);
    nonceInsance = Hive.box<Nonce>(nonceBox);
    unsignedInsance = Hive.box<StoreUnsignedMessage>(unsignedMessageBox);
    pushInsance = Hive.box<StoreSignedMessage>(pushMessageBox);
    multiMesInsance = Hive.box<StoreMultiMessage>(multiMessageBox);
    multiInsance = Hive.box<MultiSignWallet>(multiWalletBox);
    gasInsance = Hive.box<CacheGas>(gasBox);
    minerMetaInstance = Hive.box<MinerMeta>(minerMetaBox);
    minerStatisticInstance = Hive.box<MinerHistoricalStats>(minerStatisticBox);
    multiProposeInstance = Hive.box<CacheMultiMessage>(multiProposeBox);
    minerAddressInstance = Hive.box<MinerAddress>(minerAddressBox);
    multiApproveInstance = Hive.box<MultiApproveMessage>(multiApproveBox);
    minerBalanceInstance = Hive.box<MinerSelfBalance>(minerBalanceBox);
  }
  /// box to store miner meta info
  static Box<MinerMeta> get minerMetaInstance {
    return Hive.box<MinerMeta>(minerMetaBox);
  }
  /// box to store miner statistic info
  static Box<MinerHistoricalStats> get minerStatisticInstance {
    return Hive.box<MinerHistoricalStats>(minerStatisticBox);
  }
}
