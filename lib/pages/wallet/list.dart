import 'package:fil/index.dart';
import 'package:fil/pages/main/widgets/select.dart';
/// display all wallet 
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
        more: true,
        footerHeight: 120,
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
