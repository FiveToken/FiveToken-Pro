import 'dart:convert';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/message.dart';
import 'package:fil/pages/sign/signBody.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/qr.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// display a qrcode of unsigned message
class MesBodyPage extends StatefulWidget {
  @override
  State createState() => MesBodyPageState();
}

/// page of message page
class MesBodyPageState extends State<MesBodyPage> {
  TMessage message = TMessage();

  @override
  void initState() {
    super.initState();
    if(Get.arguments!=null) {
      message = Get.arguments['mes'] as TMessage;
    }
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
                          .convert(message.toLotusMessage())),
                    ),
                    onTap: () {
                      copyText(jsonEncode(message.toLotusMessage()));
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
