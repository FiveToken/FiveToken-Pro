part of 'main_bloc.dart';

@immutable
class MainState extends Equatable {
  // price.dart
  final double price;
  // sellect.dart
  final String selectType;
  //balanceMonitoring.dart
  final List<MinerAddress> nodeList;
  // powerBoard.dart
  final MinerMeta meta;
  // online.dart
  final bool enablePullUp;
  final int transferType;
  final List<StoreMessage> messageList;
  final String balance;
  final String mid;
  // miner.dart
  final MinerHistoricalStats stats;
  final MinerSelfBalance info;

  MainState({
    this.price,
    this.selectType,
    this.nodeList,
    this.meta,
    this.transferType,
    this.messageList,
    this.enablePullUp,
    this.balance,
    this.mid,
    this.stats,
    this.info,
  });

  @override
  // TODO: implement props
  List<Object> get props => [
        this.price,
        this.selectType,
        this.nodeList,
        this.meta,
        this.transferType,
        this.messageList,
        this.enablePullUp,
        this.balance,
        this.mid,
        this.stats,
        this.info
      ];

  factory MainState.idle() {
    return MainState(
      price: 0,
      selectType: WalletType.all,
      nodeList: [],
      meta: MinerMeta(),
      transferType: TransferType.all,
      messageList: [],
      enablePullUp: true,
      balance: '0',
      mid: '',
      stats: MinerHistoricalStats(),
      info: MinerSelfBalance(),
    );
  }

  MainState copyWithMainState({
    double price,
    String selectType,
    List<MinerAddress> nodeList,
    MinerMeta meta,
    int transferType,
    List<StoreMessage> messageList,
    bool enablePullUp,
    String balance,
    String mid,
    MinerHistoricalStats stats,
    MinerSelfBalance info,
  }) {
    return MainState(
        price: price ?? this.price,
        selectType: selectType ?? this.selectType,
        nodeList: nodeList ?? this.nodeList,
        meta: meta ?? this.meta,
        transferType: transferType ?? this.transferType,
        messageList: messageList ?? this.messageList,
        enablePullUp: enablePullUp ?? this.enablePullUp,
        balance: balance ?? this.balance,
        mid: mid ?? this.mid,
        stats: stats ?? this.stats,
        info: info ?? this.info);
  }
}
