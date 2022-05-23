import 'dart:convert';
import 'package:fil/common/utils.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/noop.dart';
import 'package:fil/pages/message/method.dart';
import 'package:fil/pages/transfer/detail.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// page of display message
class DisplayMessage extends StatelessWidget {
  final TMessage message;
  final Noop onTap;
  final String footerText;
  final bool hasFooter;
  DisplayMessage(
      {this.message, this.onTap, this.footerText, this.hasFooter = true});
  String get maxFee {
    var feeCap = message.gasFeeCap;
    var gasLimit = message.gasLimit;
    var maxFee =
        formatFil(BigInt.from((double.parse(feeCap) * gasLimit)).toString());
    return maxFee;
  }

  String get withdrawNum {
    try {
      if (message.args == null) {
        return '';
      } else {
        var p = jsonDecode(message.args);
        return formatFil(p['AmountRequested'] as String);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonCard(Column(
          children: [
            MessageRow(
              label: 'from'.tr,
              selectable: true,
              value: message.from,
            ),
            MessageRow(
              label: 'to'.tr,
              selectable: true,
              value: message.to,
            ),
          ],
        )),
        SizedBox(
          height: 7,
        ),
        Visibility(
          child: CommonCard(MessageRow(
            label: 'amount'.tr,
            value: formatFil(message.value),
          )),
          visible: message.method == 0,
        ),
        Visibility(
          child: CommonCard(MessageRow(
            label: 'withdrawNum'.tr,
            value: withdrawNum,
          )),
          visible: message.method == 16 && withdrawNum != '',
        ),
        SizedBox(
          height: 7,
        ),
        CommonCard(MessageRow(
          label: 'fee'.tr,
          value: maxFee,
        )),
        SizedBox(
          height: 7,
        ),
        CommonCard(Column(
          children: [
            MessageRow(
              label: 'method'.tr,
              value: MethodMap()
                  .getMethodDes(message.method.toString(), to: message.to),
            ),
            MessageRow(
              label: 'Nonce',
              value: message.nonce.toString(),
            ),
            Visibility(
                visible: hasFooter,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    height: 48,
                    child: CommonText(
                      footerText ?? 'advanced'.tr,
                      size: 14,
                      weight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                        color: CustomColor.primary,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8))),
                  ),
                ))
          ],
        ))
      ],
    );
  }
}
