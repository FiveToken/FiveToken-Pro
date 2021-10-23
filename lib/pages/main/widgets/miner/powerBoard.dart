import 'package:fil/index.dart';
import 'package:fil/pages/main/miner.dart';

class PowerBoard extends StatefulWidget {
  @override
  State createState() {
    return PowerBoardState();
  }
}

class PowerBoardState extends State<PowerBoard> {
  MinerMeta meta = MinerMeta();
  StreamSubscription sub;
  Worker worker;
  String get addr => $store.addr;
  var box = OpenedBox.minerMetaInstance;
  String get powerPercent {
    try {
      var v = double.parse(meta.percent);
      return '${v.toStringAsFixed(2)}%';
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    if (box.containsKey(addr)) {
      meta = box.get(addr);
    }
    getPowerInfo();
    worker = ever($store.wallet, (Wallet wal) {
      if (wal.walletType == 2) {
        if (box.containsKey(wal.addr)) {
          meta = box.get(addr);
          setState(() {});
        }
        getPowerInfo();
      }
    });
    sub = Global.eventBus.on<RefreshEvent>().listen((event) {
      getPowerInfo();
    });
  }

  void getPowerInfo() async {
    try {
      var res = await Global.provider.getMinerMeta($store.wal.addrWithNet);
      if (mounted) {
        box.put(addr, res);
        setState(() {
          meta = res;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
    worker.dispose();
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
          value: formatFil(meta.rewards, size: 2),
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
