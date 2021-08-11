import 'package:fil/index.dart';
import './unsigned.dart';
/// sign message
class SignIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignIndexPageState();
  }
}

class SignIndexPageState extends State<SignIndexPage> {
  TMessage message;
  SignedMessage signedMessage;
  bool showSigned = false;
  void handleScan() {
    var signMode = Global.store.getInt('signMode');
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.UnSignedMessage})
        .then((res) {
      if (res != '') {
        try {
          var mes = jsonDecode(res);
          setState(() {
            var message = TMessage.fromJson(mes);
            if (signMode == 1) {
              var cacheGas = OpenedBox.nonceInsance.get(message.from);
              if (cacheGas != null) {
                var nonce = cacheGas.value;
                var realNonce = max(nonce, message.nonce);
                message.nonce = realNonce;
              }
            }
            this.message = message;
          });
        } catch (e) {
          showCustomError('errorMesFormat'.tr);
        }
      }
    });
  }

  void signMessage(String pass) async {
    var wallet = singleStoreController.wal;
    var signMode = Global.store.getInt('signMode');
    if (message.from != wallet.addrWithNet) {
      showCustomError('fromNotMatch'.tr);
      return;
    }
    var now = (DateTime.now().millisecondsSinceEpoch / 1000).truncate();
    String sign = '';
    num signType;
    var cid =
        await Flotus.messageCid(msg: jsonEncode(message.toLotusMessage()));
    var wal = singleStoreController.wal;
    var ck = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
    if (message.from[1] == '1') {
      signType = SignTypeSecp;
      sign = await Flotus.secpSign(ck: ck, msg: cid);
    } else {
      signType = SignTypeBls;
      sign = await Bls.cksign(num: "$ck $cid");
    }
    var signedMessage = SignedMessage(message, Signature(signType, sign));
    if (signMode == 1) {
      OpenedBox.nonceInsance
          .put(message.from, Nonce(time: now, value: message.nonce + 1));
    }
    setState(() {
      showSigned = true;
      this.signedMessage = signedMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    var kH=MediaQuery.of(context).viewInsets.bottom;
    return CommonScaffold(
      title: 'second'.tr,
      footerText: showSigned ? 'close'.tr : 'signBtn'.tr,
      grey: true,
      hasFooter: kH==0,
      resizeToAvoidBottomInset: kH!=0,
      onPressed: () {
        if (showSigned) {
          Get.back();
        } else {
          if (message == null) {
            return;
          }
          showPassDialog(context, (String pass) {
            signMessage(pass);
          });
        }
      },
      actions: [ScanAction(handleScan: handleScan)],
      body: SingleChildScrollView(
        child: showSigned
            ? SignedMessageBody(signedMessage)
            : UnsignedMessage(
                onTap: handleScan,
                message: message,
                edit: (TMessage message) {
                  setState(() {
                    this.message = message;
                  });
                },
              ),
        padding: EdgeInsets.fromLTRB(12, 20, 12, 120),
      ),
    );
  }
}
