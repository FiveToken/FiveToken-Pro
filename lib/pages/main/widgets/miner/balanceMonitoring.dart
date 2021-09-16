import 'package:fbutton/fbutton.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/miner.dart';
import 'package:flutter/cupertino.dart';
class BalanceMonitoring extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BalanceMonitoringState();
  }
}

class BalanceMonitoringState extends State<BalanceMonitoring> {
  TextEditingController ctrl = TextEditingController();
  List<MinerAddress> list = [];
  StreamSubscription sub;
  var box = Hive.box<MonitorAddress>(monitorBox);
  Worker worker;
  String getTitleByTypeAndAddress(String address) {
    return box.get(address)?.label ?? '-';
  }

  void getAddressInfo() async {
    try {
      var res =
          await getMinerControllers($store.wal.addrWithNet);
      if (mounted) {
        setState(() {
          list = res;
        });
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    worker = ever($store.wallet, (Wallet wal) {
      getAddressInfo();
    });
    sub = Global.eventBus.on<RefreshEvent>().listen((event) {
      getAddressInfo();
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
    sub.cancel();
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
            element.threshold = threshold;
            box.put(element.cid, element);
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
    //var list = list;
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
              address: v.address,
              balance: getFilBalance(v.balance),
              title: getTitleByTypeAndAddress(v.address),
              type: v.type,
              gasFee: getFilBalance(v.yestodayGasFee),
              onEdit: (String addr) {
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
  final String address;
  final String balance;
  final String title;
  final String type;
  final bool bordered;
  final SingleParamCallback<String> onEdit;
  final String gasFee;
  final TextEditingController controller = TextEditingController();
  AddressItem(
      {@required this.address,
      @required this.balance,
      @required this.title,
      @required this.type,
      this.onEdit,
      this.gasFee,
      this.bordered = true});
  void handleConfirm() {
    var label = controller.text;
    if (controller.text.trim() == '') {
      showCustomError('missField'.tr);
      return;
    } else {
      var box = Hive.box<MonitorAddress>(monitorBox);
      var addr = box.get(address);
      addr.label = label;
      box.put(address, addr);
      controller.text = '';
      onEdit(address);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    var isOwner = type == 'owner';
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Colors.grey[200], width: bordered ? 0.5 : 0))),
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
                '${'monitorGas'.tr}: $gasFee',
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
              Text(dotString(str: address)),
              Text(balance),
              SizedBox(
                height: 20,
                child: FButton(
                  text: isOwner ? 'transfer'.tr : 'monitorRecharge'.tr,
                  strokeColor: Color(0xff5CC1CB),
                  onPressed: () {
                    if (isOwner) {
                      Get.toNamed(mesMakePage, arguments: {
                        'type': MessageType.OwnerTransfer,
                        'from': address
                      });
                    } else {
                      Get.toNamed(mesDepositPage, arguments: {'to': address});
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
