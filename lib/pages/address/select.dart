import 'package:fil/bloc/address/address_bloc.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// select a address when transfer
class AddressBookSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookSelectPageState();
  }
}

/// Page of select address book
class AddressBookSelectPageState extends State<AddressBookSelectPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressBloc()..add(SetAddressEvent()),
      child: BlocBuilder<AddressBloc, AddressState>(builder: (context, state) {
        return CommonScaffold(
            title: 'selectAddr'.tr,
            hasFooter: false,
            grey: false,
            actions: [
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.add_circle_outline, color: Colors.black),
                ),
                onTap: () {
                  Get.toNamed(addressAddPage).then((value) {
                    BlocProvider.of<AddressBloc>(context)
                        .add(SetAddressEvent());
                  });
                  ;
                },
              )
            ],
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(addressWalletPage).then((value) {
                        if (value != null && value is Wallet) {
                          Get.back(result: value);
                        }
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: CustomRadius.b8,
                        color: CustomColor.primary,
                      ),
                      child: Layout.rowBetween([
                        CommonText.white('inAccount'.tr, size: 15),
                        Image(
                            width: 18, image: AssetImage('images/right-w.png'))
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Column(
                    children: List.generate(
                      state.list.length,
                      (index) {
                        var wallet = state.list[index];
                        return Column(
                          children: [
                            GestureDetector(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonText.white(wallet.label, size: 15),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    CommonText.white(
                                      dotString(str: wallet.address),
                                      size: 10,
                                    ),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: CustomRadius.b8,
                                  color: CustomColor.primary,
                                ),
                              ),
                              onTap: () {
                                Get.back(result: wallet);
                              },
                            ),
                            SizedBox(
                              height: 8,
                            )
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ));
      }),
    );
  }
}
