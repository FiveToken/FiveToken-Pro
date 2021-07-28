import 'package:fil/index.dart';
import 'package:fil/pages/main/widgets/select.dart';

class WalletListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletListPageState();
  }
}

class WalletListPageState extends State<WalletListPage> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'manage'.tr,
      onPressed: () {
        Get.toNamed(createEntrancePage);
      },
      body: WalletSelect(
        bottom: 150,
        more: true,
        onTap: (Wallet wal) {
          Global.cacheWallet = wal;
          Get.toNamed(walletMangePage).then((value) {
            setState(() {});
          });
        },
      ),
      footerText: 'addWallet'.tr,
    );
  }
}
