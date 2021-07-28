import 'package:fil/index.dart';
import 'package:fil/pages/main/widgets/select.dart';

class AddressBookWalletSelect extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      hasFooter: false,
      title: 'selectWallet'.tr,
      body: WalletSelect(
        onTap: (wal){
          Get.back(result: wal);
        },
      ),
    );
  }
}