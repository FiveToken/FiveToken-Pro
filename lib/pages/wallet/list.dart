import 'package:fil/common/global.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/main/widgets/select.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// display all wallet
class WalletListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletListPageState();
  }
}

/// page of wallet code
class WalletListPageState extends State<WalletListPage> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'manage'.tr,
      onPressed: () {
        Get.toNamed(createEntrancePage);
      },
      body: WalletSelect(
        more: true,
        footerHeight: 120,
        onTap: (Wallet wal) {
          Global.cacheWallet = wal;
          Get.toNamed(walletMangePage);
        },
      ),
      footerText: 'addWallet'.tr,
    );
  }
}
