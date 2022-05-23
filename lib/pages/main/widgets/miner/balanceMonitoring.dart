import 'dart:async';
import 'package:fbutton/fbutton.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/main/miner.dart';
import 'package:fil/pages/message/make.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/fresh.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// widget of balance monitor
class BalanceMonitoring extends StatefulWidget {
  BalanceMonitoring();
  @override
  State<StatefulWidget> createState() {
    return BalanceMonitoringState();
  }
}

class BalanceMonitoringState extends State<BalanceMonitoring> {
  TextEditingController ctrl = TextEditingController();
  var box = OpenedBox.minerAddressInstance;
  List<MinerAddress> list = [];
  Worker worker;
  StreamSubscription sub;
  String getTitleByTypeAndAddress(MinerAddress address) {
    return address.label;
  }

  @override
  void initState() {
    super.initState();
    // worker = ever($store.wallet, (Wallet wal) {
    //   if (wal.walletType == WalletsType.miner) {
    //     BlocProvider.of<MainBloc>(context).add(getMinerRelatedListEvent($store.addr));
    //   }
    // });
    // sub = Global.eventBus.on<RefreshEvent>().listen((event) {
    //   BlocProvider.of<MainBloc>(context).add(getMinerRelatedListEvent($store.addr));
    // });
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

  void handleConfirm() {
    var threshold = ctrl.text.trim();
    if (threshold == '') {
      showCustomError('missField'.tr);
      return;
    } else {
      try {
        var thresholdNum = double.parse(threshold);
        if (thresholdNum is double) {
          box.values.forEach((element) {
            // element.threshold = threshold;
            box.put(element.address, element);
          });
          ctrl.text = '';
          Get.back();
        }
      } catch (e) {
        Get.back();
        showCustomError(e as String);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            MainBloc()..add(getMinerRelatedListEvent($store.addr)),
        child: BlocBuilder<MainBloc, MainState>(builder: (context, state) {
          return MinerBoard(Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.grey[200], width: .5))),
                child: Row(
                  children: [
                    IconMonitor,
                    SizedBox(
                      width: 5,
                    ),
                    BoldText(
                      'monitorTitle'.tr,
                      color: Color(0xff5CC1CB),
                    ),
                  ],
                ),
                height: 40,
              ),
              Column(
                children: state.nodeList.map((v) {
                  return AddressItem(
                    source: v,
                    title: getTitleByTypeAndAddress(v),
                    onEdit: (String label) async {
                      v.label = label;
                      await box.put(v.address + v.type, v);
                      BlocProvider.of<MainBloc>(context)
                          .add(getMinerRelatedListEvent($store.addr));
                    },
                  );
                }).toList(),
              ),
            ],
          ));
        }));
  }
}

class AddressItem extends StatelessWidget {
  final String title;
  final ValueChanged<String> onEdit;
  final MinerAddress source;
  final TextEditingController controller = TextEditingController();
  AddressItem({
    @required this.title,
    @required this.source,
    this.onEdit,
  });
  void handleConfirm() async {
    var label = controller.text;
    if (controller.text.trim() == '') {
      showCustomError('missField'.tr);
      return;
    } else {
      controller.text = '';
      onEdit(label);
    }
    Get.back();
  }

  String get type => source.type;
  @override
  Widget build(BuildContext context) {
    var isOwner = type == 'owner';
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.grey[200], width: .5))),
      child: Column(
        children: [
          Row(
            children: [
              Text(title),
              type == 'controller' || type == 'worker'
                  ? GestureDetector(
                      onTap: () {
                        controller.text = title;
                        showCustomDialog(
                            context,
                            Column(
                              children: [
                                CommonTitle(
                                  'monitorChange'.tr,
                                  showDelete: true,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Field(
                                          controller: controller,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Divider(
                                        height: 1,
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: CommonText(
                                            'sure'.tr,
                                            color: CustomColor.primary,
                                          ),
                                        ),
                                        onTap: handleConfirm,
                                        behavior: HitTestBehavior.opaque,
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.only(top: 20),
                                )
                              ],
                            ));
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(
                          Icons.edit,
                          color: Color(0xff5CC1CB),
                          size: 18,
                        ),
                      ),
                    )
                  : SizedBox(),
              Spacer(),
              CommonText(
                '${'monitorGas'.tr}: ${formatFil(source.yestodayGasFee)}',
                color: Color(0xff666666),
                weight: FontWeight.w400,
                size: 12,
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dotString(str: source.address)),
              Text(formatFil(source.balance, size: 2)),
              SizedBox(
                height: 20,
                child: FButton(
                  text: isOwner ? 'transfer'.tr : 'monitorRecharge'.tr,
                  strokeColor: Color(0xff5CC1CB),
                  onPressed: () {
                    if (isOwner) {
                      Get.toNamed(mesMakePage, arguments: {
                        'type': MessageType.OwnerTransfer,
                        'from': source.address
                      });
                    } else {
                      Get.toNamed(mesDepositPage,
                          arguments: {'to': source.address});
                    }
                  },
                  clickEffect: true,
                  shadowColor: Color.fromARGB(50, 92, 193, 203),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  cornerStyle: FCornerStyle.round,
                  corner: FCorner.all(20),
                  style: TextStyle(color: Color(0xff5CC1CB), fontSize: 11),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
