import 'dart:convert';
import 'dart:typed_data';
import 'package:fil/bloc/init/init_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/routes/path.dart';
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

/// set password of a wallet
class PassInitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PassInitPageState();
  }
}

/// page of password init
class PassInitPageState extends State<PassInitPage> {
  TextEditingController passCtrl = TextEditingController();
  TextEditingController passConfirmCtrl = TextEditingController();
  bool mneCreate;
  Wallet wallet;
  bool checkPassword(state) {
    var pass = passCtrl.text.trim();
    var confirm = passConfirmCtrl.text.trim();
    if (state.level as num < 4) {
      showCustomError('levelTips'.tr);
      return false;
    } else if (pass != confirm) {
      showCustomError('differentPassword'.tr);
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    wallet = Get.arguments['wallet'] as Wallet;
    mneCreate = Get.arguments != null && Get.arguments['create'] == true;
  }

  void handleSubmit(state) async {
    if (!checkPassword(state)) {
      return;
    }
    unFocusOf(context);
    String password = passCtrl.text.trim();
    var address = wallet.addressWithNet;
    Uint8List sk = await encryptSodium(wallet.ck, address, password);
    if (wallet.mne != '') {
      Uint8List mne = await encryptSodium(wallet.mne, address, password);
      wallet.mne = base64Encode(mne);
    }
    wallet.skKek = base64Encode(sk);
    wallet.ck = '';
    Global.store.setString('activeWalletAddress', address);
    OpenedBox.addressInsance.put(address, wallet);
    $store.setWallet(wallet);
    Get.offAllNamed(mainPage, arguments: {'create': mneCreate});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => InitBloc()..add(SetInitEvent())),
        ],
        child: BlocBuilder<InitBloc, InitState>(builder: (context, state) {
          return BlocListener<InitBloc, InitState>(
            listener: (context, state) {
              passCtrl.addListener(() {
                if (passCtrl.text != '') {
                  num level = zxcvbnLevel(passCtrl.text) as num;
                  BlocProvider.of<InitBloc>(context)
                      .add(SetInitEvent(level: level));
                }
              });
            },
            child: CommonScaffold(
              title: 'pass'.tr,
              footerText: 'next'.tr,
              onPressed: () {
                handleSubmit(state);
              },
              body: Padding(
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    PassField(
                      controller: passCtrl,
                      label: 'setPassword'.tr,
                      hintText: 'placeholderValidPass'.tr,
                    ),
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
                      height: 20,
                    ),
                    PassField(
                      controller: passConfirmCtrl,
                      label: '',
                      hintText: 'enterPassAgain'.tr,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          );
        }));
  }
}
