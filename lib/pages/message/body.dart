import 'package:fil/index.dart';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'second'.tr,
      footerText: 'next'.tr,
      onPressed: () {
        Get.toNamed(mesPushPage);
      },
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(12, 20, 12, 120),
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
            hasFooter: false,
            footerText: 'viewDetail'.tr,
            message: message,
            onTap: () {
              //show(context);
            },
          ),
        ]),
      ),
    );
  }
}
