import 'dart:convert';

import 'package:bls/bls.dart';
import 'package:fil/bloc/sign/sign_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/models/message.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/pages/sign/signed.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/other.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:flotus/flotus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import './unsigned.dart';

/// sign message
class SignIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignIndexPageState();
  }
}

/// page of sign index
class SignIndexPageState extends State<SignIndexPage> {
  void handleScan(BuildContext context) {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.UnSignedMessage})
        .then((res) {
      if (res != '') {
        try {
          var mes = jsonDecode(res as String);
          var message = TMessage.fromJson(mes as Map<String, dynamic>);
          BlocProvider.of<SignBloc>(context)
              .add(SetSignEvent(message: message));
        } catch (e) {
          showCustomError('errorMesFormat'.tr);
        }
      }
    });
  }

  void signMessage(BuildContext context, String pass, TMessage message) async {
    var wallet = $store.wal;
    if (message.from != wallet.addressWithNet) {
      showCustomError('fromNotMatch'.tr);
      return;
    }
    String sign = '';
    num signType;
    var cid =
        await Flotus.messageCid(msg: jsonEncode(message.toLotusMessage()));
    var wal = $store.wal;
    var address = wal.addressWithNet;
    var ck = await decryptSodium(wal.skKek, address, pass);
    if (message.from[1] == '1') {
      signType = SignTypeSecp;
      sign = await Flotus.secpSign(ck: ck, msg: cid);
    } else {
      signType = SignTypeBls;
      sign = await Bls.cksign(num: "$ck $cid");
    }
    var signedMessage = SignedMessage(message, Signature(signType, sign));
    BlocProvider.of<SignBloc>(context).add(SetSignEvent(
        message: message, signedMessage: signedMessage, showSigned: true));
  }

  @override
  Widget build(BuildContext context) {
    var kH = MediaQuery.of(context).viewInsets.bottom;
    return BlocProvider(
        create: (context) => SignBloc()..add(SetSignEvent()),
        child: BlocBuilder<SignBloc, SignState>(builder: (context, state) {
          return CommonScaffold(
            title: 'second'.tr,
            footerText: state.showSigned ? 'close'.tr : 'signBtn'.tr,
            grey: true,
            hasFooter: kH == 0,
            resizeToAvoidBottomInset: kH != 0,
            onPressed: () {
              if (state.showSigned) {
                Get.back();
              } else {
                if (state.message == null) {
                  return;
                }
                showPassDialog(context, (String pass) {
                  signMessage(context, pass, state.message);
                });
              }
            },
            actions: [ScanAction(handleScan: () => handleScan(context))],
            body: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  child: state.showSigned
                      ? SignedMessageBody(state.signedMessage)
                      : UnsignedMessage(
                          onTap: () => handleScan(context),
                          message: state.message,
                          edit: (TMessage message) {
                            BlocProvider.of<SignBloc>(context)
                                .add(SetSignEvent(message: message));
                          },
                        ),
                  padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
                )),
                SizedBox(
                  height: 120,
                )
              ],
            ),
          );
        }));
  }
}
