import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
/// set password of a wallet
class PassInitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PassInitPageState();
  }
}

class PassInitPageState extends State<PassInitPage> {
  TextEditingController passCtrl = TextEditingController();
  TextEditingController passConfirmCtrl = TextEditingController();
  bool mneCreate;
  Wallet wallet;
  bool checkPass() {
    var pass = passCtrl.text.trim();
    var confirm = passConfirmCtrl.text.trim();
    if (!isValidPassword(pass)) {
      showCustomError('enterValidPass'.tr);
      return false;
    } else if (pass != confirm) {
      showCustomError('diffPass'.tr);
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

  void handleSubmit() async {
    if (!checkPass()) {
      return;
    }
    unFocusOf(context);
    String pass = passCtrl.text.trim();
    var addr = wallet.addrWithNet;
    var ck = wallet.ck;
    var kek = await genKek(addr, pass);
    var pkList = base64Decode(ck);
    var skKek = xor(kek, pkList);
    if (wallet.mne != '') {
      var m = aesEncrypt(wallet.mne, ck);
      wallet.mne = m;
    }
    var digest = await genPrivateKeyDigest(ck);
    wallet.skKek = skKek;
    wallet.digest = digest;
    wallet.ck = '';
    print(wallet.toJson());
    Global.store.setString('activeWalletAddress', addr);
    OpenedBox.addressInsance.put(addr, wallet);
    $store.setWallet(wallet);
    Get.offAllNamed(mainPage, arguments: {'create': mneCreate});
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'pass'.tr,
      footerText: 'next'.tr,
      onPressed: () {
        handleSubmit();
      },
      body: Padding(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            PassField(
              controller: passCtrl,
              label: 'setPass'.tr,
              hintText: 'enterValidPass'.tr,
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
    );
  }
}
