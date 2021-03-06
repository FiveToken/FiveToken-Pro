import 'package:fil/index.dart';
/// run mode set
class WalletModePage extends StatelessWidget {
  void setMode(bool mode){
    Global.onlineMode=mode;
    Global.store.setBool('runMode', mode);
    Get.toNamed(initWalletPage);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.primary,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          child: ImageAl,
                          onTap: () {
                            Get.back();
                          },
                        )
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  ),
                  ImageFil,
                  SizedBox(
                    height: 12,
                  ),
                  CommonText(
                    'FiveToken Pro',
                    color: Colors.white,
                    size: 20,
                    weight: FontWeight.w800,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 85, 0, 13),
                    child: CommonText(
                      'selectPurpose'.tr,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  TapCard(
                    items: [
                      CardItem(
                          label: 'onlineMode'.tr,
                          onTap: () {
                            setMode(true);
                          })
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TapCard(
                    items: [
                      CardItem(
                          label: 'offlineMode'.tr,
                          onTap: () {
                            setMode(false);
                          })
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            DocButton(page: initModePage,color: Colors.white,),
            SizedBox(
              height: 10,
            ),
            CommonText(
              Global.version,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
