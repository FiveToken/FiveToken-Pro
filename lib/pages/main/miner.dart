import 'package:fil/index.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/main/widgets/miner/balanceMonitoring.dart';
import 'package:fil/pages/main/widgets/price.dart';
import 'dart:math';

class RefreshEvent {}

class MinerAddressStats extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinerAddressStatsState();
  }
}

class MinerAddressStatsState extends State<MinerAddressStats> {
  MinerMeta info = MinerMeta();
  Worker worker;
  var box = OpenedBox.minerMetaInstance;
  String get addr => $store.wal.addrWithNet;
  @override
  void initState() {
    super.initState();
    worker = ever($store.wallet, (Wallet wal) async {
      if (wal.walletType == 2) {
        if (box.containsKey(addr)) {
          info = box.get(addr);
          setState(() {});
        }
        Global.eventBus.fire(ShouldRefreshEvent());
      }
    });
    if (box.containsKey(addr)) {
      info = box.get(addr);
    }
  }

  Future getStatus(String addr) async {
    var res = await getMinerInfo(addr);
    if (res.sectorSize != 0) {
      OpenedBox.minerMetaInstance.put(addr, res);
      setState(() {
        this.info = res;
      });
    }
  }

  String get marketPrice {
    try {
      var v = double.parse(info.balance);
      var atto = BigInt.from(v * pow(10, 18));
      return getMarketPrice(atto.toString(), 7);
    } catch (e) {
      return '--';
    }
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
  }

  Future _onRefresh() async {
    Global.eventBus.fire(RefreshEvent());
    await getStatus(addr);
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshWidget(
        enablePullUp: false,
        initRefresh: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 40),
          child: Column(
            children: [
              SizedBox(
                height: 16,
              ),
              Obx(
                () => CommonText(
                  $store.wal.label,
                  size: 16,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              CommonText(
                formatDouble(info.balance, size: 4, truncate: true) + 'FIL',
                size: 30,
                weight: FontWeight.w800,
              ),
              SizedBox(
                height: 12,
              ),
              MarketPrice(
                atto: false,
                balance: info.balance,
              ),
              // CommonText(marketPrice),
              SizedBox(
                height: 18,
              ),
              Obx(() => CopyAddress($store.wal.addrWithNet)),
              SizedBox(
                height: 18,
              ),
              MinerBoard(Row(
                children: [
                  Expanded(
                      child: minerMeta(
                          'metaAvailable'.tr, getFilBalance(info.available))),
                  Expanded(
                      child: minerMeta(
                          'metaPledge'.tr, getFilBalance(info.pledge))),
                  Expanded(
                      child: minerMeta(
                          'metaLock'.tr,
                          getFilBalance(
                            info.lock,
                          ),
                          bordered: false)),
                ],
              )),
              SizedBox(
                height: 12,
              ),
              PowerBoard(info),
              SizedBox(
                height: 12,
              ),
              YestodayBoard(),
              SizedBox(
                height: 12,
              ),
              BalanceMonitoring()
            ],
          ),
        ),
        onRefresh: _onRefresh);
  }
}

Widget minerMeta(String label, String value, {bool bordered = true}) {
  return Container(
    child: Column(
      children: [
        CommonText(label),
        SizedBox(
          height: 12,
        ),
        CommonText.main(
          value,
          size: 12,
        )
      ],
    ),
  );
}

class MinerBoard extends StatelessWidget {
  final Widget child;
  MinerBoard(this.child);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(30, 0, 0, 0),
                offset: Offset(-1, 5),
                blurRadius: 20)
          ],
          color: Colors.white,
          borderRadius: CustomRadius.b6,
          border: Border.all(color: Colors.grey[100])),
    );
  }
}

class PowerBoard extends StatelessWidget {
  final MinerMeta meta;
  PowerBoard(this.meta);
  String get powerPercent {
    try {
      var v = double.parse(meta.percent);
      return '${(100 * v).toStringAsFixed(2)}%';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinerBoard(Column(
      children: [
        Row(
          children: [
            IconStats,
            SizedBox(
              width: 5,
            ),
            CommonText(
              'metaQuality'.tr,
              color: CustomColor.primary,
              weight: FontWeight.bold,
            )
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Layout.rowBetween([
          CommonText(
            unitConversion(meta.qualityPower, 2),
            weight: FontWeight.bold,
          ),
          CommonText('${'metaPercent'.tr}: $powerPercent'),
          CommonText('${'metaRank'.tr}: ${meta.rank}'),
        ]),
        Divider(),
        MinerStatusRow(
          label: 'metaRaw'.tr,
          value: unitConversion(meta.rawPower, 2),
        ),
        MinerStatusRow(
          label: 'metaBlocks'.tr,
          value: meta.blockCount.toString(),
        ),
        MinerStatusRow(
          label: 'metaRewards'.tr,
          value: getFilBalance(meta.rewards),
        ),
        MinerStatusRow(
          label: 'metaSectorSize'.tr,
          value: unitConversion(meta.sectorSize.toString(), 0),
        ),
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.main('metaSectorStatus'.tr),
              SizedBox(
                width: 100,
              ),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.end,
                text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                          text: '${meta.allSectors} ${'allSector'.tr} ',
                          style: TextStyle(fontSize: 13)),
                      TextSpan(
                          text: '${meta.liveSectors} ${'validSector'.tr} ',
                          style: TextStyle(
                              color: CustomColor.primary, fontSize: 13)),
                      TextSpan(
                          text: '${meta.faultSectors} ${'faultSector'.tr} ',
                          style:
                              TextStyle(color: CustomColor.red, fontSize: 13)),
                      TextSpan(
                          text:
                              '${meta.preCommitSectors} ${'precommitSector'.tr}',
                          style:
                              TextStyle(color: Color(0xffE8CC5C), fontSize: 13))
                    ]),
              ))
            ],
          ),
        ),
      ],
    ));
  }
}

class YestodayBoard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return YestodayBoardState();
  }
}

class YestodayBoardState extends State<YestodayBoard> {
  MinerHistoricalStats stats = MinerHistoricalStats();
  String get address => $store.wal.addrWithNet;
  Worker worker;
  StreamSubscription sub;
  var box = OpenedBox.minerStatisticInstance;
  @override
  void initState() {
    super.initState();
    if (box.containsKey(address)) {
      stats = box.get(address);
    }
    worker = ever($store.wallet, (Wallet wal) {
      if (box.containsKey(address)) {
        setState(() {
          stats = box.get(address);
        });
      }
      getYestodayInfo(wal.addrWithNet);
    });
    sub = Global.eventBus.on<RefreshEvent>().listen((event) {
      getYestodayInfo(address);
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
    sub.cancel();
  }

  void getYestodayInfo(String addr) async {
    try {
      var res = await getMinerYestodayInfo(addr);
      box.put(addr, res);
      if (mounted) {
        setState(() {
          stats = res;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String get luckyPercent {
    try {
      var v = double.parse(stats.lucky);
      return (100 * v).toStringAsFixed(2) + '%';
    } catch (e) {
      return '';
    }
  }

  String get costPerTib {
    try {
      var v = double.parse(stats.profitPerTib);
      return v.toStringAsFixed(4) + ' FIL/TiB';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MinerBoard(Column(
      children: [
        Row(
          children: [
            IconStats,
            SizedBox(
              width: 5,
            ),
            CommonText(
              'yesTitle'.tr,
              color: CustomColor.primary,
              weight: FontWeight.bold,
            )
          ],
        ),
        Divider(),
        MinerStatusRow(
          label: 'yesPowerIncr'.tr,
          value: unitConversion(stats.sector, 2),
        ),
        MinerStatusRow(
          label: 'yesGas'.tr,
          value: formatFil(stats.gasFee),
        ),
        MinerStatusRow(
          label: 'yesBlock'.tr,
          value: formatFil(stats.total),
        ),
        MinerStatusRow(
          label: 'yesLucky'.tr,
          value: luckyPercent,
        ),
        MinerStatusRow(
          label: 'yesSector'.tr,
          value: unitConversion(stats.sector, 2),
        ),
        MinerStatusRow(
          label: 'yesPerT'.tr,
          value: costPerTib,
        ),
        Divider(),
        GestureDetector(
          onTap: () {
            openInBrowser(
                '$filscanWeb/address/miner?address=$address&utm_source=filwallet_app');
          },
          child: Container(
            child: CommonText('more'.tr),
          ),
        )
      ],
    ));
  }
}

class MinerStatusRow extends StatelessWidget {
  final String label;
  final String value;
  MinerStatusRow({
    this.label,
    this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Layout.rowBetween([
        CommonText.main(label),
        CommonText(value),
      ]),
    );
  }
}
