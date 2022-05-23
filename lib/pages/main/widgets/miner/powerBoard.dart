import 'dart:async';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/main/miner.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// widget of power board
class PowerBoard extends StatefulWidget {
  @override
  State createState() {
    return PowerBoardState();
  }
}

class PowerBoardState extends State<PowerBoard> {
  StreamSubscription sub;
  Worker worker;
  String get addr => $store.addr;
  var box = OpenedBox.minerMetaInstance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if(sub!=null) {
      sub.cancel();
    }
    if(worker!=null) {
      worker.dispose();
    }
  }

  String powerPercent(MinerMeta meta) {
    try {
      var v = double.parse(meta.percent);
      return '${v.toStringAsFixed(2)}%';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            MainBloc()..add(getPowerInfoEvent($store.wal.addressWithNet)),
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
                  unitConversion(state.meta.qualityPower, 2),
                  weight: FontWeight.bold,
                ),
                CommonText('${'metaPercent'.tr}:' + powerPercent(state.meta)),
                CommonText('${'metaRank'.tr}: ${state.meta.rank}'),
              ]),
              Divider(),
              MinerStatusRow(
                label: 'metaRaw'.tr,
                value: unitConversion(state.meta.rawPower, 2),
              ),
              MinerStatusRow(
                label: 'metaBlocks'.tr,
                value: state.meta.blockCount.toString(),
              ),
              MinerStatusRow(
                label: 'metaRewards'.tr,
                value: formatFil(state.meta.rewards, size: 2),
              ),
              MinerStatusRow(
                label: 'metaSectorSize'.tr,
                value: unitConversion(state.meta.sectorSize.toString(), 0),
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
                                text:
                                    '${state.meta.allSectors} ${'allSector'.tr} ',
                                style: TextStyle(fontSize: 13)),
                            TextSpan(
                                text:
                                    '${state.meta.liveSectors} ${'validSector'.tr} ',
                                style: TextStyle(
                                    color: CustomColor.primary, fontSize: 13)),
                            TextSpan(
                                text:
                                    '${state.meta.faultSectors} ${'faultSector'.tr} ',
                                style: TextStyle(
                                    color: CustomColor.red, fontSize: 13)),
                            TextSpan(
                                text:
                                    '${state.meta.preCommitSectors} ${'precommitSector'.tr}',
                                style: TextStyle(
                                    color: Color(0xffE8CC5C), fontSize: 13))
                          ]),
                    ))
                  ],
                ),
              ),
            ],
          ));
        }));
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
