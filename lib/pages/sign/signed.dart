import 'package:fil/index.dart';
class SignedMessageBody extends StatelessWidget {
  final SignedMessage signedMessage;
  SignedMessageBody(this.signedMessage);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12, 20, 12, 120),
      child: Layout.colStart([
        CommonText(
          'hasSign'.tr,
          size: 16,
          weight: FontWeight.w500,
        ),
        Container(
          child: CommonText('useReadonly'.tr),
          padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 12),
          padding: EdgeInsets.all(30),
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: CustomRadius.b6),
          child: QrImageView(
            jsonEncode(signedMessage),
            size: Get.width - 120,
          ),
        ),
        DisplayMessage(
          footerText: 'viewDetail'.tr,
          message: signedMessage.message,
          onTap: () {
            showCustomModalBottomSheet(
                shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 500,
                    child: Layout.colStart([
                      CommonTitle(
                        'detail'.tr,
                        showDelete: true,
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                        child: CommonText(JsonEncoder.withIndent(" ")
                            .convert(signedMessage.toLotusSignedMessage())),
                      )
                    ]),
                  );
                });
            //show(context);
          },
        ),
      ]),
    );
  }
}
