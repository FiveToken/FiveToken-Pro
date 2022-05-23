import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/bloc/multiDetail/multi_detail_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/wallet/code.dart';
import 'package:fil/store/store.dart';
import 'package:fil/style/index.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// display signers and threshold of the multi-sig wallet
class MultiDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiDetailPageState();
  }
}

/// page of multi detail
class MultiDetailPageState extends State<MultiDetailPage> {
  MultiSignWallet wallet = $store.multiWal;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var addr = wallet.addressWithNet;
    // var signers = wallet.signers;
    return BlocProvider(
        create: (context) => MultiDetailBloc()
          ..add(getMultiMessageDetailEvent($store.multiWal.addressWithNet)),
        child: BlocBuilder<MultiDetailBloc, MultiDetailState>(
            builder: (context, state) {
          return CommonScaffold(
            title: 'multiAccountInfo'.tr,
            barColor: CustomColor.primary,
            titleColor: Colors.white,
            background: CustomColor.primary,
            hasFooter: false,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Image(
                width: 20,
                image: AssetImage("images/back-w.png"),
              ),
              alignment: NavLeadingAlign,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20),
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WalletQrCode(addr),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Column(
                              children: [
                                CommonText(state.signers.length.toString()),
                                SizedBox(
                                  height: 5,
                                ),
                                CommonText('memberNum'.tr)
                              ],
                            )),
                            Expanded(
                                child: Column(
                              children: [
                                CommonText(wallet.threshold.toString()),
                                SizedBox(
                                  height: 5,
                                ),
                                CommonText('threshold'.tr)
                              ],
                            )),
                          ],
                        ),
                        Divider(),
                        CommonText.main('memberAddr'.tr),
                        SizedBox(
                          height: 5,
                        ),
                        Column(
                          children:
                              List.generate(state.signers.length, (index) {
                            var signer = state.signers[index] as String;
                            return GestureDetector(
                              onTap: () {
                                copyText(signer);
                                showCustomToast('copyAddr'.tr);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: index ==
                                                    state.signers.length - 1
                                                ? Colors.transparent
                                                : Colors.grey[200]))),
                                child: CommonText(signer),
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: CustomRadius.b6,
                        border: Border.all(color: Colors.grey[200])),
                  )
                ],
              ),
            ),
          );
        }));
  }
}
