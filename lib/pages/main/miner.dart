import 'package:fil/index.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/main/widgets/miner/balanceMonitoring.dart';
import 'package:fil/pages/main/widgets/price.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  StreamSubscription sub;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();

    worker = ever(singleStoreController.wallet, (Wallet wal) async {
      if(wal.walletType==2){
        _refreshController.requestRefresh();
      }
    });
    sub = Global.eventBus.on<AppStateChangeEvent>().listen((event) {
      getStatus();
    });
    nextTick(() {
      _refreshController.requestRefresh();
    });
  }

  Future getStatus() async {
    var res = await getMinerInfo(singleStoreController.wal.addrWithNet);
    if (res.sectorSize != 0) {
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
    sub.cancel();
  }

  void _onRefresh() async {
    Global.eventBus.fire(RefreshEvent());
    await getStatus();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: WaterDropHeader(
        waterDropColor: CustomColor.primary,
        complete: Text('finish'.tr),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 40),
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Obx(
              () => CommonText(
                singleStoreController.wal.label,
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
            Obx(() => CopyAddress(singleStoreController.wal.addrWithNet)),
            SizedBox(
              height: 18,
            ),
            MinerBoard(Row(
              children: [
                Expanded(
                    child: minerMeta(
                        'metaAvailable'.tr, getFilBalance(info.available))),
                Expanded(
                    child:
                        minerMeta('metaPledge'.tr, getFilBalance(info.pledge))),
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
    );
  }
}

Widget minerMeta(String label, String value, {bool bordered = true}) {
  return Container(
    // decoration: BoxDecoration(
    //     border: Border(
    //         right:
    //             BorderSide(color: Colors.grey[100], width: bordered ? 0 : 0))),
    //padding: EdgeInsets.symmetric(vertical: 15),
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
  String address = singleStoreController.wal.addrWithNet;
  Worker worker;
  StreamSubscription sub;
  StreamSubscription sub2;
  @override
  void initState() {
    super.initState();
    getYestodayInfo();
    worker = ever(singleStoreController.wallet, (Wallet wal) {
      getYestodayInfo();
    });
    sub = Global.eventBus.on<AppStateChangeEvent>().listen((event) {
      getYestodayInfo();
    });
    sub2 = Global.eventBus.on<RefreshEvent>().listen((event) {
      getYestodayInfo();
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
    sub.cancel();
    sub2.cancel();
  }

  void getYestodayInfo() async {
    try {
      var res =
          await getMinerYestodayInfo(singleStoreController.wal.addrWithNet);
      print(res);
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
            openInBrowser('https://filscan.io/address/miner?address=$address&utm_source=filwallet_app');
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
