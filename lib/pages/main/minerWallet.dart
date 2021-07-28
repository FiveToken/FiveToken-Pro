import 'package:fil/index.dart';
import 'package:fil/pages/main/miner.dart';
import 'package:oktoast/oktoast.dart';
import 'widgets/miner/balanceMonitoring.dart';

class MinerWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinerWalletState();
  }
}

class MinerWalletState extends State<MinerWallet> {
  MinerMeta meta = MinerMeta();
  MinerHistoricalStats historicalStats = MinerHistoricalStats();
  List<MinerAddress> addressList = [];
  String owner;
  Box<MinerInfo> minerBox = Hive.box<MinerInfo>(minerDetailBox);
  Worker worker;
  @override
  void initState() {
    super.initState();
    var addr = singleStoreController.wal.addrWithNet;
    var hasCache = minerBox.containsKey(addr);
    MinerInfo info = minerBox.get(addr);
    if (hasCache) {
      // MinerInfo info = minerBox.get(addr);
      setData(info, init: true);
    }
    getMinerStatsInfo(addr);
    worker = ever(singleStoreController.wallet, (Wallet v) {
      if (v.walletType == 2) {
        if (minerBox.containsKey(v.addr)) {
          setData(minerBox.get(v.addr));
        }
        getMinerStatsInfo(v.addr);
      }
    });
  }

  // @override
  // void didUpdateWidget(covariant MinerWallet oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.address != widget.address) {
  //     getMinerStatsInfo(widget.address);
  //   }
  // }
  @override
  void dispose() {
    super.dispose();
    worker.dispose();
  }

  Future getMinerStatsInfo(String address) async {
    try {
      bool hasCache = minerBox.containsKey(address);
      if (!hasCache) {
        showCustomLoading('Loading');
      }
    } catch (e) {
      print(e);
    }
    Future.wait([getMinerInfo(address), getMinerStats(address)])
        .then((resultLists) {
      dismissAllToast();
      meta = resultLists[0];
      var stats = resultLists[1] as MinerStats;
      MinerInfo info = MinerInfo(meta: meta, stats: stats);
      minerBox.put(address, info);
      nextTick(() => setData(info));
    }).catchError((dynamic v) {
      print(v);
      dismissAllToast();
    });
  }

  void setData(MinerInfo info, {bool init = false}) {
    if (mounted) {
      var stats = info.stats;
      var meta = info.meta;
      var setD = () {
        this.meta = meta;
        this.historicalStats = stats.historicalStats;
        this.addressList = stats.addressList;
        this.owner = stats.owner;
      };
      if (init) {
        setD();
      } else {
        setState(() {
          setD();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            MinerAddressStats(),
            // MetaBoard(meta, owner),
            // HistoricalStats(historicalStats),
            BalanceMonitoring()
          ],
        ));
  }
}
