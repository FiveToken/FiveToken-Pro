import 'dart:ui';
import 'package:fil/pages/other/webview.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class DocLink {
  final String zh;
  final String en;
  const DocLink({this.zh, this.en});
  String get link {
    if (Get.locale.languageCode == 'zh') {
      return zh;
    } else {
      return en;
    }
  }

  static DocLink get mainDocLink => const DocLink(
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html',
      en: 'https://docs.fivetoken.io/userguide/proapp.html');
  static DocLink get transferLink => const DocLink(
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html#%E7%A6%BB%E7%BA%BF%E4%BA%A4%E6%98%93',
      en: 'https://docs.fivetoken.io/userguide/proapp.html#offline-transaction');
  static DocLink get withdrawalLink => const DocLink(
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html#%E7%9F%BF%E5%B7%A5%E6%8F%90%E7%8E%B0',
      en: 'https://docs.fivetoken.io/userguide/proapp.html#miner-withdrawal');
  static DocLink get changeOwnerLink => const DocLink(
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html#%E7%9F%BF%E5%B7%A5%E6%9B%B4%E6%8D%A2owner%E5%9C%B0%E5%9D%80',
      en: 'https://docs.fivetoken.io/userguide/proapp.html#miners-change-owner-address');
  static DocLink get changeWorkerLink => const DocLink(
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html#%E7%9F%BF%E5%B7%A5%E6%9B%B4%E6%8D%A2worker%E3%80%81controller%E5%9C%B0%E5%9D%80',
      en: 'https://docs.fivetoken.io/userguide/proapp.html#miner-replace-the-worker-and-controller-address');
  static DocLink get pushLink => const DocLink(
      en: 'https://docs.fivetoken.io/userguide/proapp.html#message-push',
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html#%E6%B6%88%E6%81%AF%E6%8E%A8%E9%80%81');
  static DocLink get createMultiLink => const DocLink(
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html#%E5%A4%9A%E7%AD%BE%E9%92%B1%E5%8C%85%E7%9A%84%E4%BD%BF%E7%94%A8',
      en: 'https://docs.fivetoken.io/userguide/proapp.html#use-of-multi-signature-wallet');
  static DocLink get importMultiLink => const DocLink(
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html#%E5%AF%BC%E5%85%A5%E5%A4%9A%E7%AD%BE%E5%9C%B0%E5%9D%80',
      en: 'https://docs.fivetoken.io/userguide/proapp.html#import-a-multi-signature-address');
  static DocLink get proposeLink => const DocLink(
      zh: 'https://docs.fivetoken.io/cn/userguide/proapp.html#%E5%A4%9A%E7%AD%BE%E5%9C%B0%E5%9D%80%E5%8F%91%E9%80%81%E4%BA%A4%E6%98%93',
      en: 'https://docs.fivetoken.io/userguide/proapp.html#multi-signature-address-sending-transaction');
}

class DocButton extends StatelessWidget {
  final String method;
  final String page;
  final Color color;
  DocButton({this.method, this.page, this.color});
  String get link {
    DocLink l = DocLink.mainDocLink;
    switch (page) {
      case mesMakePage:
        var map = <String, DocLink>{
          '0': DocLink.transferLink,
          '3': DocLink.changeOwnerLink,
          '16': DocLink.withdrawalLink,
          '23': DocLink.changeWorkerLink
        };
        if (map.containsKey(method)) {
          l = map[method];
        } else {
          l = DocLink.transferLink;
        }

        break;
      case mesPushPage:
        l = DocLink.pushLink;
        break;
      case multiImportPage:
        l = DocLink.importMultiLink;
        break;
      case multiCreatePage:
        l = DocLink.createMultiLink;
        break;
      case multiProposalPage:
        l = DocLink.proposeLink;
        break;
      default:
    }
    return l.link;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 20,
              color: color ?? CustomColor.grey,
            ),
            SizedBox(
              width: 5,
            ),
            CommonText(
              'helpCenter'.tr,
              color: color ?? CustomColor.grey,
            )
          ],
        ),
        onTap: () {
          goWebviewPage(url: link);
        },
      ),
    );
  }
}
