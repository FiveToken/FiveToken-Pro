import 'dart:async';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/main/widgets/miner/balanceMonitoring.dart';
import 'package:fil/pages/main/widgets/miner/powerBoard.dart';
import 'package:fil/pages/main/widgets/price.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/fresh.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshEvent {}

/// miner address
class MinerAddressStats extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinerAddressStatsState();
  }
}

/// page of miner address
class MinerAddressStatsState extends State<MinerAddressStats> {
  Worker worker;
  var box = OpenedBox.minerBalanceInstance;
  List<MinerAddress> relatedList = [];
  String get addr => $store.wal.addressWithNet;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if(worker!=null) {
      worker.dispose();
    }
  }

  Future _onRefresh(BuildContext context) async {
    BlocProvider.of<MainBloc>(context)
        .add(getMinerBalanceInfoEvent($store.wal.addressWithNet));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MainBloc()
          ..add(getMinerBalanceInfoEvent($store.wal.addressWithNet)),
        child: BlocBuilder<MainBloc, MainState>(builder: (context, state) {
          return CustomRefreshWidget(
            enablePullUp: false,
            initRefresh: true,
            onRefresh: () {
              _onRefresh(context);
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
                      state.info.total,
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
                    balance: state.info.total,
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Obx(() => CopyAddress($store.wal.addressWithNet)),
                  SizedBox(
                    height: 18,
                  ),
                  MinerBoard(Row(
                    children: [
                      Expanded(
                          child: minerMeta('metaAvailable'.tr,
                              formatFil(state.info.available, size: 2))),
                      Expanded(
                          child: minerMeta('metaPledge'.tr,
                              formatFil(state.info.pledge, size: 2))),
                      Expanded(
                          child: minerMeta('metaLock'.tr,
                              formatFil(state.info.locked, size: 2),
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
          );
        }));
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
  String get address => $store.wal.addressWithNet;
  Worker worker;
  StreamSubscription sub;
  var box = OpenedBox.minerStatisticInstance;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if(worker!=null) {
      worker.dispose();
    }
    if(sub!=null) {
      sub.cancel();
    }
  }

  void getYesterdayInfo(String addr) async {}

  String luckyPercent(String lucky) {
    try {
      var v = double.parse(lucky);
      return (100 * v).toStringAsFixed(2) + '%';
    } catch (e) {
      return '';
    }
  }

  String costPerTib(String profitPerTib) {
    try {
      var v = double.parse(profitPerTib);
      return v.toStringAsFixed(4) + ' FIL/TiB';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MainBloc()
          ..add(getMinerYesterdayInfoEvent($store.wal.addressWithNet)),
        child: BlocBuilder<MainBloc, MainState>(builder: (context, state) {
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
                value: unitConversion(state.stats.sector, 2),
              ),
              MinerStatusRow(
                label: 'yesGas'.tr,
                value: formatFil(state.stats.gasFee, returnRaw: true),
              ),
              MinerStatusRow(
                label: 'yesBlock'.tr,
                value: formatFil(state.stats.total, size: 2),
              ),
              MinerStatusRow(
                label: 'yesLucky'.tr,
                value: luckyPercent(state.stats.lucky),
              ),
              MinerStatusRow(
                label: 'yesSector'.tr,
                value: unitConversion(state.stats.sector, 2),
              ),
              MinerStatusRow(
                label: 'yesPerT'.tr,
                value: costPerTib(state.stats.profitPerTib),
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
        }));
  }
}
