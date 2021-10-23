import 'package:fil/index.dart';
import 'dart:convert';

/// display a qrcode of unsigned message
class MesBodyPage extends StatefulWidget {
  @override
  State createState() => MesBodyPageState();
}

class MesBodyPageState extends State<MesBodyPage> {
  TMessage message = TMessage();

  @override
  void initState() {
    super.initState();
    message = Get.arguments['mes'] as TMessage;
    // setState(() {
    //   message = Get.arguments['mes'];
    //   message.args = Get.arguments['args'] ?? '';
    // });
  }

  void showDetail() {
    showCustomModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 500,
            child: Column(
              children: [
                CommonTitle(
                  'detail'.tr,
                  showDelete: true,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]),
                          borderRadius: CustomRadius.b6),
                      child: CommonText(JsonEncoder.withIndent(' ')
                          .convert(message.toJson())),
                    ),
                    onTap: () {
                      copyText(jsonEncode(message.toJson()));
                      showCustomToast('copySucc'.tr);
                    },
                  ),
                ))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'second'.tr,
      footerText: 'next'.tr,
      onPressed: () {
        Get.toNamed(mesPushPage);
      },
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
            child: Layout.colStart([
              CommonText(
                'sign'.tr,
                size: 16,
                weight: FontWeight.w500,
              ),
              Container(
                child: CommonText('offlineSign'.tr),
                padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 12),
                padding: EdgeInsets.all(30),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b6),
                child: QrImageView(
                  jsonEncode(message),
                  size: Get.width - 120,
                ),
              ),
              DisplayMessage(
                  footerText: 'viewDetail'.tr,
                  message: message,
                  onTap: showDetail),
            ]),
          )),
          SizedBox(
            height: 120,
          )
        ],
      ),
    );
  }
}
