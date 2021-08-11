import 'package:fil/index.dart';
/// create or import different wallet 
class CreateEntrancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isOnline = Global.onlineMode;
    return CommonScaffold(
        hasFooter: false,
        title: 'create'.tr,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                'hdW'.tr,
                size: 14,
              ),
              SizedBox(
                height: 12,
              ),
              TabCard(
                items: [
                  CardItem(
                      label: 'createWallet'.tr,
                      onTap: () {
                        Get.toNamed(createWarnPage);
                      })
                ],
              ),
              SizedBox(
                height: 12,
              ),
              TabCard(
                items: [
                  CardItem(
                      label: 'pkImport'.tr,
                      onTap: () {
                        Get.toNamed(importPrivateKeyPage);
                      }),
                  CardItem(
                      label: 'mneImport'.tr,
                      onTap: () {
                        Get.toNamed(importMnePage);
                      })
                ],
              ),
              Visibility(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 12),
                      child: CommonText(
                        'readonlyW'.tr,
                        size: 14,
                      ),
                    ),
                    TabCard(
                      items: [
                        CardItem(
                            label: 'importReadonly'.tr,
                            onTap: () {
                              Get.toNamed(readonlyPage);
                            })
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 12),
                      child: CommonText(
                        'minerW'.tr,
                        size: 14,
                      ),
                    ),
                    TabCard(
                      items: [
                        CardItem(
                            label: 'importMiner'.tr,
                            onTap: () {
                              Get.toNamed(minerPage);
                            })
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
                visible: isOnline,
              )
            ],
          ),
        ));
  }
}
