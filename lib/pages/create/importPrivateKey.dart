import 'dart:convert';
import 'package:bls/bls.dart';
import 'package:fil/api/update.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/private.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:flotus/flotus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// import wallet by private key
class ImportPrivateKeyPage extends StatefulWidget {
  @override
  State createState() => ImportPrivateKeyPageState();
}

/// page of import privateKey
class ImportPrivateKeyPageState extends State<ImportPrivateKeyPage> {
  TextEditingController inputControl = TextEditingController();
  TextEditingController nameControl = TextEditingController();
  void _genWalletByPkAndType(String inputStr, String type, String name) async {
    String pk = '';
    String signType = SignSecp;
    try {
      if (type == '1') {
        pk = await Flotus.secpPrivateToPublic(ck: inputStr);
      } else {
        signType = SignBls;
        pk = await Bls.pkgen(num: inputStr);
      }
      if (pk == "") {
        showCustomError('wrongPk'.tr);
        return;
      }
      String address = await Flotus.genAddress(pk: pk, t: signType);
      address = Global.netPrefix + address.substring(1);
      var exist = OpenedBox.addressInsance.containsKey(address);
      if (exist) {
        showCustomError('errorExist'.tr);
        return;
      }
      Wallet wallet = Wallet(
          ck: inputStr,
          address: address,
          label: name,
          mne: '',
          walletType: 0,
          type: type);
      Get.toNamed(passwordSetPage, arguments: {'wallet': wallet});
      addOperation('import_private_key');
    } catch (e) {
      showCustomError('wrongPk'.tr);
    }
  }

  /// hanlde import privateKey
  void _handleImport(BuildContext context) {
    var inputStr = inputControl.text.trim();
    var name = nameControl.text;
    if (inputStr == "") {
      showCustomError('enterPk'.tr);
      return;
    }
    if (name == '') {
      showCustomError('enterName'.tr);
      return;
    }
    try {
      PrivateKey privateKey = PrivateKey.fromMap(
          jsonDecode(hex2str(inputStr)) as Map<String, dynamic>);
      var type = privateKey.type;
      var key = privateKey.privateKey;
      if (type == 'secp256k1') {
        _genWalletByPkAndType(key, '1', name);
      } else if (type == 'bls') {
        _genWalletByPkAndType(key, '3', name);
      } else {
        showCustomError('wrongPk'.tr);
      }
    } catch (e) {
      showCustomError('wrongPk'.tr);
    }
  }

  /// handle scan
  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.PrivateKey})
        .then((value) {
      try {
        inputControl.text = value as String;
      } catch (e) {
        showCustomError('wrongPk'.tr);
      }
    });
  }

  @override
  void dispose() {
    inputControl.dispose();
    nameControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        title: 'importPk'.tr,
        footerText: 'import'.tr,
        onPressed: () {
          _handleImport(context);
        },
        actions: [
          Padding(
            child: GestureDetector(
                onTap: handleScan,
                child: Image(
                  width: 20,
                  image: AssetImage('images/scan.png'),
                )),
            padding: EdgeInsets.only(right: 10),
          )
        ],
        body: Padding(
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    'pk'.tr,
                    weight: FontWeight.w500,
                    size: 14,
                  ),
                  GestureDetector(
                    child:
                        Image(width: 20, image: AssetImage('images/cop.png')),
                    onTap: () async {
                      var data = await Clipboard.getData(Clipboard.kTextPlain);
                      inputControl.text = data.text;
                    },
                  )
                ],
              ),
              SizedBox(
                height: 13,
              ),
              Container(
                child: TextField(
                  decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none),
                  maxLines: 6,
                  controller: inputControl,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    _handleImport(context);
                  },
                  autofocus: false,
                ),
                padding: EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
              ),
              SizedBox(
                height: 13,
              ),
              Field(
                label: 'walletName'.tr,
                controller: nameControl,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
          ),
        ));
  }
}
