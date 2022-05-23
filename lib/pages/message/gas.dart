import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/gas.dart';
import 'package:fil/models/message.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// customize gas fee
class MessageGasPage extends StatefulWidget {
  @override
  State createState() => MessageGasPageState();
}

/// page of message gas
class MessageGasPageState extends State<MessageGasPage> {
  TextEditingController feeCapCtrl = TextEditingController();
  TextEditingController gasLimitCtrl = TextEditingController();
  TextEditingController premiumCtrl = TextEditingController();
  int index = 0;
  Gas chainGas = Gas();
  Gas get gas {
    return $store.gas.value;
  }

  String get feePrice {
    return getMarketPrice($store.maxFeeNum, Global.price);
  }

  void handleSubmit(BuildContext context) {
    final feeCap = feeCapCtrl.text.trim();
    final gasLimit = gasLimitCtrl.text.trim();
    final premium = premiumCtrl.text.trim();
    if (feeCap == '' || gasLimit == '' || premium == '') {
      showCustomError('errorSetGas'.tr);
      return;
    }
    var mes = TMessage.fromJson($store.confirmMes.toJson());
    mes.gasFeeCap = feeCap;
    mes.gasLimit = num.parse(gasLimit);
    mes.gasPremium = premium;
    $store.setConfirmMessage(mes);
    unFocusOf(context);
    Get.back();
  }

  @override
  void initState() {
    super.initState();
    syncGas($store.confirmMes.gas);
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
              padding: EdgeInsets.fromLTRB(12, 16, 12, 12),
              decoration: BoxDecoration(
                  borderRadius: CustomRadius.b8, color: Color(0xff5C8BCB)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText.white('fee'.tr),
                      Obx(() => CommonText.white(
                          formatFil($store.confirmMes.maxFee.toString()),
                          size: 18))
                    ],
                  ),
                  // SizedBox(
                  //   height: 8,
                  // ),
                  // Container(
                  //   alignment: Alignment.bottomRight,
                  //   child: CommonText.white(feePrice, size: 10),
                  // )
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
            Container(
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
