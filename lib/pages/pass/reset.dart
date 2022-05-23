import 'dart:convert';
import 'dart:typed_data';
import 'package:fil/bloc/init/init_bloc.dart';
import 'package:fil/bloc/reset/reset_bloc.dart';
import 'package:fil/chain/filecoinWallet.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/pass.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/strengthPassword.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// reset password of the wallet
class PassResetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PassResetPageState();
  }
}

/// page of password reset
class PassResetPageState extends State<PassResetPage> {
  final TextEditingController oldCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController newConfirmCtrl = TextEditingController();
  var box = OpenedBox.addressInsance;
  Future<bool> checkValid(state) async {
    var old = oldCtrl.text.trim();
    var newP = newCtrl.text.trim();
    var newCp = newConfirmCtrl.text.trim();
    if (old == '') {
      showCustomError('enterOldPass'.tr);
      return false;
    }
    var wal = $store.wal;
    var address = wal.addressWithNet;
    var valid =
        await FilecoinWallet.validatePrivateKey(wal.skKek, address, old);
    if (!valid) {
      showCustomError('wrongOldPass'.tr);
      return false;
    }
    if (state.level as num < 4) {
      showCustomError('levelTips'.tr);
      return false;
    }
    if (newP != newCp) {
      showCustomError('differentPassword'.tr);
      return false;
    }
    return true;
  }

  void handleConfirm(state) async {
    var valid = await checkValid(state);
    if (!valid) {
      return;
    } else {
      var pass = newCtrl.text.trim();
      var oldPass = oldCtrl.text.trim();
      var wal = $store.wal;
      var address = wal.addressWithNet;
      String mne = '';
      try {
        mne = await decryptSodium(wal.mne, address, oldPass);
      } catch (e) {
        print(e);
      }
      if (wal.mne != '') {
        Uint8List mneEncrypt = await encryptSodium(mne, address, pass);
        wal.mne = base64Encode(mneEncrypt);
      }
      String sk = await decryptSodium(wal.skKek, address, oldPass);
      Uint8List skKek = await encryptSodium(sk, address, pass);
      wal.skKek = base64Encode(skKek);
      OpenedBox.addressInsance.put(address, wal);
      Global.cacheWallet = wal;
      $store.setWallet(wal);
      Get.back();
      showCustomToast('changePassSucc'.tr);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ResetBloc()..add(SetResetEvent())),
        ],
        child: BlocBuilder<ResetBloc, ResetState>(builder: (context, state) {
          return BlocListener<ResetBloc, ResetState>(
            listener: (context, state) {
              newCtrl.addListener(() {
                if (newCtrl.text != '') {
                  num level = zxcvbnLevel(newCtrl.text) as num;
                  BlocProvider.of<ResetBloc>(context)
                      .add(SetResetEvent(level: level));
                }
              });
            },
            child: CommonScaffold(
              title: 'pass'.tr,
              footerText: 'change'.tr,
              onPressed: () => handleConfirm(state),
              body: Padding(
                child: Column(
                  children: [
                    PassField(label: 'oldPass'.tr, controller: oldCtrl),
                    SizedBox(
                      height: 15,
                    ),
                    PassField(
                        label: 'newPass'.tr,
                        hintText: 'placeholderValidPass'.tr,
                        controller: newCtrl),
                    CustomPaint(
                      painter: StrengthPassword(
                          level: state.level, context: context),
                      child: Center(),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: CommonText(
                          'strengthTips'.tr,
                          size: 14,
                          color: Colors.black,
                          weight: FontWeight.w500,
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    PassField(
                        hintText: 'enterPassAgain'.tr,
                        controller: newConfirmCtrl),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              ),
            ),
          );
        }));
  }
}
