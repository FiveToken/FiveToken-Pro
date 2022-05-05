import 'package:fil/pages/main/widgets/select.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// display all wallet address
/// page of address book
class AddressBookWalletSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      hasFooter: false,
      title: 'selectWallet'.tr,
      body: WalletSelect(
        onTap: (wal) {
          Get.back(result: wal);
        },
      ),
    );
  }
}
