import 'dart:convert';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/event/index.dart';
import 'package:fil/models/gas.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// page of message confirm
class MessageConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var args = Get.arguments ?? {};
    return CommonScaffold(
      footerText: args['footer'] as String ?? '',
      title: args['title'] as String ?? "",
      onPressed: () {
        Global.eventBus.fire(GasConfirmEvent());
      },
      body: Obx(() {
        var message = $store.confirmMes;
        var method = message.method;
        var isWithdraw = method == 16;
        var amount = BigInt.tryParse(message.value) ?? BigInt.zero;
        var withdraw = BigInt.zero;
        var hasAmount = method == 0;
        if ([2, 16].contains(method) && message.args != null) {
          var args = jsonDecode(message.args);
          if (method == 16) {
            withdraw = BigInt.tryParse(args['AmountRequested'] as String);
          } else {
            var m = args['Method'];
            if (m == 16) {
              var inner = jsonDecode(message.innerArgs);
              withdraw = BigInt.tryParse(inner['AmountRequested'] as String);
              isWithdraw = true;
            }
            if (m == 0) {
              amount = BigInt.tryParse(args['Value'] as String) ?? BigInt.zero;
              hasAmount = true;
            }
          }
        }
        var fee = message.maxFee;
        var total = amount + fee;
        var realNum = isWithdraw ? withdraw.toString() : amount.toString();
        var color = Color(0xff999999);
        return Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(dotString(str: message.from)),
                    Container(
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      decoration: BoxDecoration(
                          color: Color(0Xffbbbbbb),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    CommonText(dotString(str: message.to)),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Visibility(
                child: Field(
                  label: isWithdraw ? 'withdrawNum'.tr : 'amount'.tr,
                  enabled: false,
                  textColor: color,
                  controller: TextEditingController(
                      text: formatFil(realNum, returnRaw: true)),
                ),
                visible: isWithdraw || hasAmount,
              ),
              SetGas(maxFee: formatFil(message.maxFee.toString())),
              SizedBox(
                height: 6,
              ),
              Field(
                label: 'totalPay'.tr,
                enabled: false,
                textColor: color,
                extra: Padding(
                  child: CommonText(
                    hasAmount ? 'Amount + Gas fee' : 'Gas fee',
                    color: color,
                  ),
                  padding: EdgeInsets.only(
                    right: 12,
                  ),
                ),
                controller: TextEditingController(
                    text: formatFil(total.toString(), returnRaw: true)),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// widget of set gas
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                color: Color(0xff5C8BCB), borderRadius: CustomRadius.b8),
            child: Row(
              children: [
                CommonText.white(maxFee, size: 16),
                Spacer(),
                CommonText.white('advanced'.tr, size: 16),
                Image(width: 18, image: AssetImage('images/right-w.png'))
              ],
            ),
          )
        ],
      ),
      onTap: () {
        Get.toNamed(mesGasPage, arguments: {'gas': gas});
      },
    );
  }
}
