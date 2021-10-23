import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/widgets/select.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:oktoast/oktoast.dart';

/// miner deposit
class DepositPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DepositPageState();
  }
}

class DepositPageState extends State<DepositPage> {
  String type = '1';
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  TextEditingController valueCtrl = TextEditingController();
  TextEditingController methodCtrl = TextEditingController();
  bool fromEnabled = true;
  num nonce;
  @override
  void initState() {
    super.initState();
    methodCtrl.text = 'Transfer (0)';
    if (Get.arguments != null) {
      toCtrl.text = Get.arguments['to'] ?? "";
    }
  }

  void handleTypeChange(dynamic value) {
    setState(() {
      this.type = value;
      if (value == '2') {
        fromCtrl.text = '';
        fromEnabled = false;
      } else {
        fromEnabled = true;
      }
    });
  }

  void confirm() async {
    var from = fromCtrl.text.trim();
    var to = toCtrl.text;
    var value = valueCtrl.text.trim();
    try {
      double.parse(value);
      value = fil2Atto(value);
    } catch (e) {
      showCustomError('enterValidAmount'.tr);
      return;
    }
    if (from == '' || value == '') {
      showCustomError('missField'.tr);
      return;
    }
    if (type == '1') {
      var res = await Global.provider
          .buildMessage({'from': from, 'to': to, 'value': value, 'method': 0});
      if (res.value != null) {
        unFocusOf(context);
        $store.setPushBackPage(mainPage);
        Get.toNamed(mesBodyPage, arguments: {'mes': res});
      }
    } else {
      if (!$store.canPush) {
        showCustomLoading('Loading');
        var valid = await Global.provider.getNonceAndGas(to: from);
        dismissAllToast();
        if (!valid) {
          showCustomError('errorSetGas'.tr);
          return;
        }
      }
      var wal = OpenedBox.addressInsance.get(from);
      showPassDialog(context, (String pass) async {
        var g = $store.gas.value;
        var msg = TMessage(
            version: 0,
            method: 0,
            nonce: $store.nonce,
            from: from,
            to: to,
            params: "",
            value: value,
            gasFeeCap: g.feeCap,
            gasLimit: g.gasLimit,
            gasPremium: g.premium);

        var private = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
        try {
          await Global.provider.sendMessage(
              message: msg,
              private: private,
              callback: (res) {
                Get.back();
              });
        } catch (e) {
          print(e);
          showCustomError(getErrorMessage(e.toString()));
        }
      }, from: wal);
    }
  }

  void showWallet() {
    showCustomModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: context,
        builder: (BuildContext context) {
          return ConstrainedBox(
              child: Column(
                children: [
                  Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            topLeft: Radius.circular(8)),
                        color: CustomColor.primary),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Image(
                            width: 20,
                            image: AssetImage('images/close.png'),
                          ),
                          onTap: () {
                            Get.back();
                          },
                        ),
                        CommonText('selectWallet'.tr, color: Colors.white),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: WalletSelect(
                    filterType: type != '1' ? 'hd' : 'readonly',
                    onTap: (Wallet wallet) {
                      var from = wallet.addrWithNet;
                      Get.back();
                      fromCtrl.text = from;
                      if (type == '2') {
                        Global.provider.getNonceAndGas(from: from);
                      }
                    },
                  ))
                ],
              ),
              constraints: BoxConstraints(maxHeight: 800));
        });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: type == '1' ? 'mesMake'.tr : 'depositRecharge'.tr,
      onPressed: confirm,
      actions: [
        ScanAction(handleScan: () {
          Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
              .then((scanResult) {
            if (scanResult != '') {
              if (!isValidAddress(scanResult)) {
                showCustomError('wrongAddr'.tr);
              }
              fromCtrl.text = scanResult;
            }
          });
        })
      ],
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  BoldText(
                    'select'.tr,
                  ),
                  Spacer(),
                  Radio(
                      activeColor: CustomColor.primary,
                      value: "1",
                      groupValue: type,
                      onChanged: handleTypeChange),
                  Text('off'.tr),
                  Radio(
                    activeColor: CustomColor.primary,
                    value: "2",
                    groupValue: type,
                    onChanged: handleTypeChange,
                  ),
                  Text('on'.tr)
                ],
              ),
            ),
            Field(
              controller: fromCtrl,
              label: 'from'.tr,
              enabled: fromEnabled,
              extra: GestureDetector(
                  child: Padding(
                    child:
                        Image(width: 20, image: AssetImage('images/book.png')),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onTap: showWallet),
            ),
            Field(
              controller: toCtrl,
              label: 'to'.tr,
              enabled: false,
            ),
            Field(
              controller: methodCtrl,
              label: 'method'.tr,
              enabled: false,
            ),
            Field(
                label: 'amount'.tr,
                controller: valueCtrl,
                type: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                ]),
            Visibility(
              child: Obx(() => SetGas(
                    maxFee: $store.maxFee,
                    gas: $store.chainGas,
                  )),
              visible: type == '2',
            ),
            type == '1' ? Tips(['depositDes'.tr]) : Container()
          ],
        ),
        padding: EdgeInsets.fromLTRB(12, 20, 12, 100),
      ),
      footerText: 'sure'.tr,
    );
  }
}

class Tips extends StatelessWidget {
  final List<String> content;
  Tips(this.content);
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      CommonText(
        'depositTips'.tr,
      ),
      Divider(),
    ];
    content.forEach((element) {
      children.add(CommonText(
        element,
        size: 12,
        color: Colors.grey[500],
      ));
    });
    return Container(
      color: Colors.grey[200],
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
