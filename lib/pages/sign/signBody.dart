import 'package:fil/index.dart';

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
        CommonCard(MessageRow(
          label: 'amount'.tr,
          value: atto2Fil(message.value) + ' FIL',
        )),
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
              value: MethodMap.getMethodDes(message.method.toString(),
                  to: message.to),
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
