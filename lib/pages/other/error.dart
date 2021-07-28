// import 'package:apkhash/apkhash.dart';
import 'package:fil/index.dart';

class ErrorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ErrorPageState();
  }
}

class ErrorPageState extends State<ErrorPage> {
  String hash = '';
  void onPress() {
    var store = Global.store;
    store.setBool('ignoreDeviceCheck', true);
    var activeStr = store.getString('activeWalletAddress');
    if (activeStr != null) {
      //Get.offAllNamed(userWalletPage);
    } else {
      Get.offAllNamed(introPage);
    }
  }

  String get msg {
    
    return '';
  }

  @override
  void initState() {
    super.initState();
  }

  // void getHash() async {
  //   var hash = await Apkhash.getHash;
  //   setState(() {
  //     this.hash = hash;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Error',
      hasFooter: false,
      hasLeading: false,
      onPressed: onPress,
      body: Container(
        child: Column(
          children: [
            CommonText(
              msg,
              size: 16,
            ),
            CommonText(hash)
          ],
        ),
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(15, 100, 15, 0),
      ),
    );
  }
}
