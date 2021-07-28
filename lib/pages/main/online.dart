import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/widgets/service.dart';
import 'package:fil/widgets/dialog.dart';
import 'messageList.dart';

class OnlineWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OnlineWalletState();
  }
}

class OnlineWalletState extends State<OnlineWallet> {
  final TextEditingController controller = TextEditingController();
  var box = Hive.box<Wallet>(addressBox);
  var multiBox = OpenedBox.multiInsance;
  List<MultiSignWallet> multiList = [];
  Timer timer;
  FilPrice price = FilPrice();
  Box<Nonce> nonceBoxInstance = OpenedBox.nonceInsance;
  void getPrice() async {
    var res = await getFilPrice();
    Global.price = res;
    if (res.cny != 0) {
      setState(() {
        this.price = res;
      });
    }
  }

  void setList() {
    var signer = singleStoreController.wal.addrWithNet;
    setState(() {
      var l = multiBox.values.where((wal) {
        return wal.signers.contains(signer);
      }).toList();
      l.sort((a, b) {
        if (a.blockTime != null && b.blockTime != null) {
          return b.blockTime.compareTo(a.blockTime);
        } else {
          return -1;
        }
      });

      multiList = l;
    });
  }

  double get rate {
    var lang = Global.langCode;
    lang = 'en';
    return lang == 'en' ? price.usd : price.cny;
  }
  
  @override
  void initState() {
    super.initState();
    getPrice();
    updateBalance();
    var isCreate = false;
    if (Get.arguments != null && Get.arguments['create'] != null) {
      isCreate = Get.arguments['create'] as bool;
    }
    var show = Get.arguments != null && isCreate == true;
    if (show) {
      showChangeNameDialog();
    }
  }

  void showChangeNameDialog() {
    Future.delayed(Duration.zero).then((value) {
      controller.text = singleStoreController.wal.label;
      showCustomDialog(
          context,
          Container(
            child: Column(
              children: [
                CommonTitle(
                  'makeName'.tr,
                  showDelete: true,
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Field(
                          //autofocus: true,
                          controller: controller,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
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
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: CommonText(
                            'sure'.tr,
                            color: CustomColor.primary,
                          ),
                        ),
                        onTap: () {
                          var v = controller.text;
                          v = v.trim();
                          if (v == "") {
                            showCustomError('enterName'.tr);
                            return;
                          }
                          if (v.length > 20) {
                            showCustomError('nameTooLong'.tr);
                            return;
                          }
                          var wallet = singleStoreController.wal;
                          wallet.label = v;
                          box.put(wallet.address, wallet);
                          singleStoreController.changeWalletName(v);
                          unFocusOf(context);
                          Get.back();
                          showCustomToast('createSucc'.tr);
                        },
                        behavior: HitTestBehavior.opaque,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(top: 20),
                )
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xfff8f8f8),
            ),
          ));
    });
  }

  void updateBalance() async {
    var wal = singleStoreController.wal;
    var res = await getBalance(wal);
    if (res.nonce == -1) {
      return;
    }
    wal.balance = res.balance;
    timer = null;
    singleStoreController.changeWalletBalance(res.balance);
    OpenedBox.addressInsance.put(wal.address, wal);
  }

  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((value) async {
      if (value != null && isValidAddress(value)) {
        Get.toNamed(filTransferPage, arguments: {'to': value});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Obx(
          () => CommonText(
            formatFil(singleStoreController.wal.balance),
            size: 30,
            weight: FontWeight.w800,
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Obx(() => CommonText(
            getMarketPrice(singleStoreController.wal.balance, rate))),
        SizedBox(
          height: 18,
        ),
        Obx(() => CopyAddress(singleStoreController.wal.addrWithNet)),
        SizedBox(
          height: 18,
        ),
        Obx(() => singleStoreController.wal.readonly == 0
            ? HdService()
            : ReadonlyService()),
        SizedBox(
          height: 40,
        ),
        Expanded(
            child: Obx(() => CommonOnlineWallet(
                  address: singleStoreController.wal.addrWithNet,
                )))
      ],
    );
  }
}

String getMarketPrice(String balance, double rate) {
  if (rate == null) {
    rate = 0;
  }
  try {
    var b = double.parse(balance) / pow(10, 18);
    var code = 'en';
    var unit = code == 'en' ? '\$' : '¥';
    return rate == 0
        ? '--'
        : ' $unit ${formatDouble((rate * b).toStringAsFixed(2))}';
  } catch (e) {
    print(e);
    return '--';
  }
}

class CopyAddress extends StatelessWidget {
  final String address;
  CopyAddress(this.address);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 25,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: CommonText(
            dotString(str: address),
            size: 14,
            color: Color(0xffB4B5B7),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Color(0xfff8f8f8)),
        ),
        SizedBox(
          width: 14,
        ),
        GestureDetector(
          onTap: () {
            copyText(address);
            showCustomToast('copyAddr'.tr);
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: CustomColor.primary,
                borderRadius: BorderRadius.circular(5)),
            child: Image(
                fit: BoxFit.fitWidth,
                width: 17,
                height: 17,
                image: AssetImage('images/copy-w.png')),
          ),
        )
      ],
    );
  }
}

class ChangeNameDialog extends StatelessWidget {
  final TextEditingController controller;
  final Noop onTap;
  ChangeNameDialog({this.controller, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CommonTitle(
            'makeName'.tr,
            showDelete: true,
          ),
          Container(
            child: Column(
              children: [
                Container(
                  child: Field(
                    //autofocus: true,
                    controller: controller,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
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
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CommonText(
                      'sure'.tr,
                      color: CustomColor.primary,
                    ),
                  ),
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 20),
          )
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xfff8f8f8),
      ),
    );
  }
}
