import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter/cupertino.dart';

/// transfer page
class FilTransferNewPage extends StatefulWidget {
  @override
  State createState() => FilTransferNewPageState();
}

class FilTransferNewPageState extends State<FilTransferNewPage>
    with RouteAware {
  String balance;
  TextEditingController _amountCtl = TextEditingController();
  TextEditingController _addressCtl = TextEditingController();
  StoreController controller = $store;
  int nonce;
  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();
  Gas chainGas;
  var nonceBoxInstance = Hive.box<Nonce>(nonceBox);
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['to'] != null) {
      _addressCtl.text = Get.arguments['to'];
    }
    FilecoinProvider.getNonceAndGas();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {});
  }

  @override
  void dispose() {
    $store.setGas(Gas());
    _amountCtl.dispose();
    _addressCtl.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// increase gas and resend a blocked message
  void speedup(String private) async {
    var res =
        await FilecoinProvider.speedup(private: private, gas: $store.gas.value);
    if (res != '') {
      Get.back();
    }
  }

  /// push message
  void _pushMsg(String ck) async {
    if (!Global.online) {
      showCustomError('errorNet'.tr);
      return;
    }
    var from = controller.wal.addrWithNet;
    var to = _addressCtl.text.trim();
    var value = fil2Atto(_amountCtl.text.trim());
    var msg = TMessage(
        version: 0,
        method: 0,
        nonce: $store.nonce,
        from: from,
        to: to,
        params: "",
        value: value,
        gasFeeCap: controller.gas.value.feeCap,
        gasLimit: controller.gas.value.gasLimit,
        gasPremium: controller.gas.value.premium);
    var res = await FilecoinProvider.sendMessage(message: msg, private: ck);
    if (res != '' && mounted) {
      Get.back();
    }
  }

  bool checkInputValid() {
    var amount = _amountCtl.text;
    var toAddress = _addressCtl.text;
    var trimAmount = amount.trim();
    var feeCap = controller.gas.value.feeCap;
    var gasLimit = controller.gas.value.gasLimit;
    if (trimAmount == "" || !isDecimal(trimAmount)) {
      showCustomError('enterValidAmount'.tr);
      return false;
    }
    var a = double.parse(trimAmount);
    if (a == 0) {
      showCustomError('enterValidAmount'.tr);
      return false;
    }
    var balance = double.parse(controller.wal.balance);
    var amountAtto = double.parse(fil2Atto(trimAmount));
    var maxFee = double.parse(feeCap) * gasLimit;

    if (balance < amountAtto + maxFee) {
      showCustomError('errorLowBalance'.tr);
      return false;
    }
    var trimAddress = toAddress.trim();
    if (trimAddress == "") {
      showCustomError('enterTo'.tr);
      return false;
    }
    if (!isValidAddress(trimAddress)) {
      showCustomError('errorAddr'.tr);
      return false;
    }
    if (trimAddress == $store.wal.addr) {
      showCustomError('errorFromAsTo'.tr);
      return false;
    }

    return true;
  }

  String get maxFee {
    return formatFil(controller.gas.value.attoFil);
  }

  void checkInputToGetGas(String v) {
    v = v.trim();
    if (v != '' && isValidAddress(v)) {
      FilecoinProvider.getGas(to: v);
    }
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((scanResult) {
      if (scanResult != '') {
        if (isValidAddress(scanResult)) {
          _addressCtl.text = scanResult;
        } else {
          showCustomError('errorAddr'.tr);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'send'.tr,
      footerText: 'next'.tr,
      actions: [
        Padding(
          child: GestureDetector(
              onTap: handleScan,
              child: Image(
                width: 20,
                image: AssetImage('images/scan.png'),
              )),
          padding: EdgeInsets.only(right: 10),
        )
      ],
      onPressed: () async {
        if (!checkInputValid()) {
          return;
        }
        var handle = () {
          var pushNew = () {
            showCustomModalBottomSheet(
                shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
                context: context,
                builder: (BuildContext context) {
                  return ConstrainedBox(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 30),
                      child: ConfirmSheet(
                        from: controller.wal.address,
                        to: _addressCtl.text,
                        gas: controller.maxFee,
                        value: _amountCtl.text,
                        onConfirm: (String ck) {
                          _pushMsg(ck);
                        },
                      ),
                    ),
                    constraints: BoxConstraints(maxHeight: 800),
                  );
                });
          };
          FilecoinProvider.checkSpeedUpOrMakeNew(
              context: context,
              onNew: pushNew,
              onSpeedup: () async {
                showPassDialog(context, (String pass) async {
                  var wal = $store.wal;
                  var ck =
                      await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
                  speedup(ck);
                });
              });
        };
        if (!$store.canPush) {
          var valid = await FilecoinProvider.getNonceAndGas(
              to: _addressCtl.text.trim());
          if (valid) {
            handle();
          } else {
            showCustomError("errorSetGas".tr);
          }
        } else {
          handle();
        }
      },
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Field(
              controller: _addressCtl,
              label: 'to'.tr,
              onChanged: (v) {
                checkInputToGetGas(v);
              },
              extra: GestureDetector(
                child: Padding(
                  child: Image(width: 20, image: AssetImage('images/book.png')),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onTap: () {
                  Get.toNamed(addressSelectPage).then((value) {
                    if (value != null) {
                      _addressCtl.text = (value as Wallet).address;
                    }
                  });
                },
              ),
            ),
            Field(
              controller: _amountCtl,
              type: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [PrecisionLimitFormatter(18)],
              label: 'amount'.tr,
              append: Obx(() => CommonText(
                    formatFil(controller.wal.balance),
                    color: CustomColor.grey,
                  )),
            ),
            Obx(() => SetGas(
                  maxFee: $store.maxFee,
                  gas: $store.chainGas,
                )),
          ],
        ),
      ),
    );
  }
}

class SpeedupSheet extends StatelessWidget {
  final Noop onSpeedUp;
  final Noop onNew;
  SpeedupSheet({this.onSpeedUp, this.onNew});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTitle(
          'sendConfirm'.tr,
          showDelete: true,
        ),
        Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText('hasPending'.tr),
                SizedBox(
                  height: 15,
                ),
                TabCard(
                  items: [
                    CardItem(
                      label: 'speedup'.tr,
                      onTap: () {
                        Get.back();
                        onSpeedUp();
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                TabCard(
                  items: [
                    CardItem(
                      label: 'continueNew'.tr,
                      onTap: () {
                        Get.back();
                        onNew();
                      },
                    )
                  ],
                ),
              ],
            ))
      ],
    );
  }
}

class ConfirmSheet extends StatelessWidget {
  final String from;
  final String to;
  final String gas;
  final String value;
  final SingleStringParamFn onConfirm;
  final Widget footer;
  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  ConfirmSheet(
      {this.from, this.to, this.gas, this.value, this.onConfirm, this.footer});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTitle(
          'sendConfirm'.tr,
          showDelete: true,
        ),
        Container(
          color: CustomColor.bgGrey,
          child: Column(
            children: [
              Container(
                padding: padding,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.grey('from'.tr),
                        Container(
                          width: 50,
                        ),
                        Expanded(
                            child: Text(
                          from,
                          textAlign: TextAlign.right,
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.grey('to'.tr),
                        Container(
                          width: 50,
                        ),
                        Expanded(
                            child: Text(
                          to,
                          textAlign: TextAlign.right,
                        )),
                      ],
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText.grey('amount'.tr),
                    CommonText(
                      '-$value Fil',
                      size: 18,
                      color: CustomColor.primary,
                      weight: FontWeight.w500,
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [CommonText.grey('fee'.tr), CommonText.main(gas)],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 30,
              ),
              footer ??
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(const Radius.circular(8)),
                      color: CustomColor.primary,
                    ),
                    child: FlatButton(
                      child: Text(
                        'send'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                        showPassDialog(context, (String pass) async {
                          var wal = $store.wal;
                          var ck = await getPrivateKey(
                              wal.addrWithNet, pass, wal.skKek);
                          onConfirm(ck);
                        });
                      },
                      //color: Colors.blue,
                    ),
                  )
            ],
          ),
          padding: EdgeInsets.fromLTRB(12, 15, 12, 20),
        )
      ],
    );
  }
}

class SetGas extends StatelessWidget {
  final String maxFee;
  final Gas gas;
  SetGas({@required this.maxFee, this.gas});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: CommonText.main('fee'.tr),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(
                color: Color(0xff5C8BCB), borderRadius: CustomRadius.b8),
            child: Row(
              children: [
                CommonText(
                  maxFee,
                  size: 14,
                  color: Colors.white,
                ),
                Spacer(),
                CommonText(
                  'advanced'.tr,
                  color: Colors.white,
                  size: 14,
                ),
                Image(width: 18, image: AssetImage('images/right-w.png'))
              ],
            ),
          )
        ],
      ),
      onTap: () {
        Get.toNamed(filGasPage, arguments: {'gas': gas});
      },
    );
  }
}
