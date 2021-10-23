import 'package:fil/index.dart';
/// display signers and threshold of the multi-sig wallet
class MultiDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiDetailPageState();
  }
}

class MultiDetailPageState extends State<MultiDetailPage> {
  MultiSignWallet wallet = $store.multiWal;
  @override
  Widget build(BuildContext context) {
    var addr = wallet.addrWithNet;
    var signers = wallet.signers;
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
        padding: EdgeInsets.only(
          bottom: 20
        ),
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
              margin: EdgeInsets.symmetric(
                horizontal: 25
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          CommonText(signers.length.toString()),
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
                    children: List.generate(signers.length, (index) {
                      var signer = signers[index];
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
                                      color: index == signers.length - 1
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
  }
}
