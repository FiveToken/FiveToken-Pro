import 'package:fil/index.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/main/widgets/miner/balanceMonitoring.dart';
import 'package:fil/pages/main/widgets/miner/powerBoard.dart';
import 'package:fil/pages/main/widgets/price.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshEvent {}

class MinerAddressStats extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinerAddressStatsState();
  }
}

class MinerAddressStatsState extends State<MinerAddressStats> {
  MinerSelfBalance info = MinerSelfBalance();
  Worker worker;
  var box = OpenedBox.minerBalanceInstance;
  List<MinerAddress> relatedList = [];
  String get addr => $store.wal.addrWithNet;
  RefreshController rc;
  @override
  void initState() {
    super.initState();
    worker = ever($store.wallet, (Wallet wal) async {
      if (wal.walletType == 2) {
        if (box.containsKey(addr)) {
          info = box.get(addr);
          setState(() {});
        }
        rc.requestRefresh();
      }
    });
    if (box.containsKey(addr)) {
      info = box.get(addr);
    }
  }

  Future getStatus(String addr) async {
    try {
      var balance = await Global.provider.getMinerBalanceInfo(addr);
      OpenedBox.minerBalanceInstance.put(addr, balance);
      if (mounted) {
        setState(() {
          this.info = balance;
          // this.relatedList = res.relatedAddress;
        });
      }
    } catch (e) {
      print(e);
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
        onInit: (rc) {
          this.rc = rc;
        },
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
                formatFil(
                  info.total,
                  size: 4,
                ),
                size: 30,
                weight: FontWeight.w800,
              ),
              SizedBox(
                height: 12,
              ),
              MarketPrice(
                atto: true,
                balance: info.total,
              ),
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
                      child: minerMeta('metaAvailable'.tr,
                          formatFil(info.available, size: 2))),
                  Expanded(
                      child: minerMeta(
                          'metaPledge'.tr, formatFil(info.pledge, size: 2))),
                  Expanded(
                      child: minerMeta(
                          'metaLock'.tr, formatFil(info.locked, size: 2),
                          bordered: false)),
                ],
              )),
              SizedBox(
                height: 12,
              ),
              PowerBoard(),
              SizedBox(
                height: 12,
              ),
              YesterdayBoard(),
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

class YesterdayBoard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return YesterdayBoardState();
  }
}

class YesterdayBoardState extends State<YesterdayBoard> {
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
      getYesterdayInfo(wal.addrWithNet);
    });
    sub = Global.eventBus.on<RefreshEvent>().listen((event) {
      getYesterdayInfo(address);
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
    sub.cancel();
  }

  void getYesterdayInfo(String addr) async {
    try {
      var res = await Global.provider.getMinerYesterdayInfo(addr);
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
          value: formatFil(stats.gasFee, returnRaw: true),
        ),
        MinerStatusRow(
          label: 'yesBlock'.tr,
          value: formatFil(stats.total, size: 2),
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
            var url =
                '$filscanWeb/address/miner?address=$address&utm_source=filwallet_app';
            goWebviewPage(url: url, title: 'detail'.tr);
          },
          child: Container(
            child: CommonText('more'.tr),
          ),
        )
      ],
    ));
  }
}
