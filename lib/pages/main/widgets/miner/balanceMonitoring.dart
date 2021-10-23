import 'package:fbutton/fbutton.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/miner.dart';
import 'package:flutter/cupertino.dart';
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
    var list = box.values.where((m) => m.miner == $store.addr).toList();
    if (list.isNotEmpty) {
      this.list = list;
    }
    getRelatedList($store.addr);
    worker = ever($store.wallet, (Wallet wal) {
      if (wal.walletType == 2) {
        var list = box.values.where((m) => m.miner == wal.addr).toList();
        if (list.isNotEmpty) {
          setState(() {
            this.list = list;
          });
        }
        getRelatedList(wal.addr);
      }
    });
    sub = Global.eventBus.on<RefreshEvent>().listen((event) {
      getRelatedList($store.addr);
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
    sub.cancel();
  }

  void getRelatedList(String addr) async {
    try {
      var res = await Global.provider.getMinerRelatedAddressBalance(addr);
      Map<String, String> labelMap = {};
      box.values.where((element) => element.miner == addr).forEach((e) {
        labelMap[e.address + e.type] = e.label;
      });
      await box.deleteAll(labelMap.keys);
      for (var i = 0; i < res.length; i++) {
        var addr = res[i];
        var key = addr.address + addr.type;
        if (labelMap.containsKey(key)) {
          var label = labelMap[key];
          addr.label = label;
        } else {
          addr.label = addr.type;
        }
        box.put(key, addr);
      }
      if (mounted) {
        setState(() {
          list = res;
        });
      }
    } catch (e) {
      print(e);
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
        showCustomError(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var ownerIndex = list.indexWhere((element) => element.type == 'owner');
    if (ownerIndex >= 0) {
      var owner = list.removeAt(ownerIndex);
      list.add(owner);
    }
    return MinerBoard(Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey[200], width: .5))),
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
          children: list.map((v) {
            return AddressItem(
              source: v,
              title: getTitleByTypeAndAddress(v),
              onEdit: (String label) async {
                v.label = label;
                await box.put(v.address + v.type, v);
                setState(() {});
              },
            );
          }).toList(),
        ),
      ],
    ));
  }
}

class AddressItem extends StatelessWidget {
  final String title;
  final SingleParamCallback<String> onEdit;
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
