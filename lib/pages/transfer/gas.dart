
import 'package:fil/index.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/store/store.dart';
/// customize gas fee
class FilGasPage extends StatefulWidget {
  @override
  State createState() => FilGasPageState();
}

class FilGasPageState extends State<FilGasPage> {
  StoreController controller = $store;
  TextEditingController feeCapCtrl = TextEditingController();
  TextEditingController gasLimitCtrl = TextEditingController();
  TextEditingController premiumCtrl = TextEditingController();
  int index = 0;
  Gas chainGas = Gas();
  Color getTextColor(bool filter) {
    return filter ? Colors.white : CustomColor.grey;
  }

  Gas get gas {
    return $store.gas.value;
  }

  int get premium {
    try {
      var p = int.parse(gas.premium);
      return p;
    } catch (e) {
      return 0;
    }
  }

  String get fastFeeCap {
    return chainGas.feeCap;
  }

  String get slowFeeCap {
    try {
      var feeCapNum = int.parse(chainGas.feeCap);
      var feeCap = (0.9 * feeCapNum).truncate().toString();
      return feeCap.toString();
    } catch (e) {
      return chainGas.feeCap;
    }
  }

  String get feePrice {
    return getMarketPrice(
        $store.maxFeeNum, Global.price?.rate);
  }

  void handleSubmit(BuildContext context) {
    final feeCap = feeCapCtrl.text.trim();
    final gasLimit = gasLimitCtrl.text.trim();
    final premium = premiumCtrl.text.trim();
    if (feeCap == '' || gasLimit == '' || premium == '') {
      showCustomError('errorSetGas'.tr);
      return;
    }
    controller.setGas(Gas(
        feeCap: feeCap,
        gasLimit: num.parse(gasLimit),
        premium: premium,
        level: index));
    unFocusOf(context);
    Get.back();
  }

  @override
  void initState() {
    super.initState();
    index = gas.level;
    if (Get.arguments != null && Get.arguments['gas'] != null) {
      chainGas = Get.arguments['gas'] as Gas;
      syncGas(chainGas);
    }
    if (index == 2) {
      syncGas(controller.gas.value);
    }
  }

  void syncGas(Gas g) {
    feeCapCtrl.text = g.feeCap;
    gasLimitCtrl.text = g.gasLimit.toString();
    premiumCtrl.text = g.premium;
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).viewInsets.bottom;
    return CommonScaffold(
      title: 'advanced'.tr,
      footerText: 'sure'.tr,
      onPressed: () {
        handleSubmit(context);
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 20, 12, h + 100),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 10),
              decoration: BoxDecoration(
                  borderRadius: CustomRadius.b8, color: Color(0xff5C8BCB)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText.white('fee'.tr),
                      Obx(() => CommonText.white($store.maxFee,
                          size: 18))
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: CommonText.white(feePrice, size: 10),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText.main('feeRate'.tr),
                  // Image(
                  //   width: 20,
                  //   image: AssetImage('images/que.png'),
                  // )
                ],
              ),
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: CustomRadius.b8,
                    color: index == 0 ? CustomColor.primary : Colors.white),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'fast'.tr,
                          color: getTextColor(index == 0),
                        ),
                        CommonText(
                          fastFeeCap,
                          size: 10,
                          color: getTextColor(index == 0),
                        )
                      ],
                    )),
                    CommonText(
                      '<1${'minute'.tr}',
                      color: getTextColor(index == 0),
                    )
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  index = 0;
                  chainGas.level = 0;
                  var g = Gas(
                      level: 0,
                      feeCap: chainGas.feeCap,
                      gasLimit: chainGas.gasLimit,
                      premium: chainGas.premium);
                  $store.setGas(g);
                  syncGas(g);
                });
              },
            ),
            SizedBox(
              height: 7,
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: CustomRadius.b8,
                    color: index == 1 ? CustomColor.primary : Colors.white),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'normal'.tr,
                          color: getTextColor(index == 1),
                        ),
                        CommonText(
                          slowFeeCap,
                          size: 10,
                          color: getTextColor(index == 1),
                        ),
                      ],
                    )),
                    CommonText(
                      '<3${'minute'.tr}',
                      color: getTextColor(index == 1),
                    )
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  index = 1;
                  try {
                    var n = int.parse(chainGas.feeCap);
                    var feeCapNum=(0.9 * n).truncate();
                    var feeCap = feeCapNum.toString();
                    var g = Gas(
                        level: 1,
                        premium: (feeCapNum-100).toString(),
                        feeCap: feeCap,
                        gasLimit: chainGas.gasLimit);
                    $store.setGas(g);
                    syncGas(g);
                  } catch (e) {}
                });
              },
            ),
            SizedBox(
              height: 7,
            ),
            index != 2
                ? GestureDetector(
                    onTap: () {
                      // syncGas();
                      setState(() {
                        index = 2;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: CommonText.grey('custom'.tr),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: CustomColor.primary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.white('custom'.tr),
                        Divider(
                          color: Colors.white,
                        ),
                        CommonText.white('GasFeeCap', size: 10),
                        Field(
                          label: '',
                          controller: feeCapCtrl,
                          type: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        CommonText.white('GasPremium', size: 10),
                        Field(
                          label: '',
                          controller: premiumCtrl,
                          type: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        CommonText.white('GasLimit', size: 10),
                        Field(
                          label: '',
                          controller: gasLimitCtrl,
                          type: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

