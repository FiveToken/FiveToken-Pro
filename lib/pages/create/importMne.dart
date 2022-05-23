import 'package:bls/bls.dart';
import 'package:fil/api/update.dart';
import 'package:fil/common/global.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/wallet.dart';
import 'package:flotus/flotus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// import wallet by mne
class ImportMnePage extends StatefulWidget {
  @override
  State createState() => ImportMnePageState();
}

/// page of import mne
class ImportMnePageState extends State<ImportMnePage> {
  TextEditingController inputControl = TextEditingController();
  TextEditingController nameControl = TextEditingController();
  bool checkValidate() {
    String inputStr = inputControl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    String label = nameControl.text.trim();
    if (inputStr == "") {
      showCustomError('enterMne'.tr);
      return false;
    }
    if (label == "") {
      showCustomError('enterName'.tr);
      return false;
    }
    if (!bip39.validateMnemonic(inputStr)) {
      showCustomError('wrongMne'.tr);
      return false;
    }
    return true;
  }

  /// handle import mne
  void handleImport(BuildContext context, String type) async {
    String inputStr = inputControl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    String label = nameControl.text.trim();
    String pk = '';
    String ck = '';
    String signType = SignSecp;
    unFocusOf(context);
    if (type == '1') {
      ck = genCKBase64(inputStr);
      pk = await Flotus.secpPrivateToPublic(ck: ck);
    } else {
      signType = SignBls;
      var key = bip39.mnemonicToSeed(inputStr);
      ck = await Bls.ckgen(num: key.join(""));
      pk = await Bls.pkgen(num: ck);
    }
    String address = await Flotus.genAddress(pk: pk, t: signType);
    address = Global.netPrefix + address.substring(1);
    var exist = OpenedBox.addressInsance.containsKey(address);
    if (exist) {
      showCustomError('errorExist'.tr);
      return;
    }
    addOperation('import_mne');
    Wallet wallet = Wallet(
      ck: ck,
      address: address,
      label: label,
      walletType: 0,
      type: type,
      mne: inputStr,
    );
    Get.toNamed(passwordSetPage, arguments: {'wallet': wallet});
  }

  /// handle scan
  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Mne}).then((value) {
      try {
        //var ck = aesDecrypt(value, tokenify('filwallet'));
        inputControl.text = value as String;
      } catch (e) {
        showCustomError('wrongMne'.tr);
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
        title: 'importMne'.tr,
        footerText: 'import'.tr,
        onPressed: () {
          if (!checkValidate()) {
            return;
          } else {
            showWalletSelector(context, (String type) {
              handleImport(context, type);
            });
          }
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
                    'mne'.tr,
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
                      hintText: 'enterMne'.tr,
                      hintStyle:
                          TextStyle(color: Color(0xffcccccc), fontSize: 14),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none),
                  maxLines: 6,
                  controller: inputControl,
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
