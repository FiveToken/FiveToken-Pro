
import 'package:fil/index.dart';



void tapSign(List<MultiSignWallet> multiList) {
  var comleteList = multiList.where((wal) => wal.status == 1).toList();
  if (comleteList.isEmpty) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: Get.context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTitle(
                  'select'.tr,
                  showDelete: true,
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabCard(
                        items: [
                          CardItem(
                            label: 'createMulti'.tr,
                            onTap: () {
                              Get.back();
                              Get.toNamed(multiCreatePage);
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TabCard(
                        items: [
                          CardItem(
                            label: 'importMulti'.tr,
                            onTap: () {
                              Get.back();
                              Get.toNamed(multiImportPage);
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  } else {
    // if ($store.multiWal == null ||
    //     $store.multiWal.id == '' ||
    //     !($store.multiWal.signers is List &&
    //         $store.multiWal.signers
    //             .contains($store.wal.addrWithNet))) {
    //   $store.setMultiWallet(comleteList[0]);
    //   Global.store.setString('activeMultiAddress', comleteList[0].addrWithNet);
    // }

    // Get.toNamed(multiMainPage);
    if (comleteList.length == 1) {
      
      $store.setMultiWallet(comleteList[0]);
      Global.store.setString('activeMultiAddress', comleteList[0].addrWithNet);
      Get.toNamed(multiMainPage);
    } else {
      showMultiWalletSelector(Get.context, () {
        Get.toNamed(multiMainPage);
      });
    }
  }
}

List<MultiSignWallet> getList() {
  var signer = $store.wal.addrWithNet;
  var l = OpenedBox.multiInsance.values.where((wal) {
    return wal.signers.contains(signer);
  }).toList();
  l.sort((a, b) {
    if (a.blockTime != null && b.blockTime != null) {
      return b.blockTime.compareTo(a.blockTime);
    } else {
      return -1;
    }
  });
  return l;
}

class HdService extends StatelessWidget {
  List<MultiSignWallet> get multiList => getList();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(walletCodePage);
                // Get.toNamed(signIndexPage);
              },
              path: 'send.png',
              color: CustomColor.primary,
            ),
            CommonText(
              'rec'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
        SizedBox(
          width: 30,
        ),
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(filTransferPage);
              },
              path: 'rec.png',
              color: Color(0xff5C8BCB),
            ),
            CommonText(
              'send'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
        SizedBox(
          width: 30,
        ),
        Column(
          children: [
            IconBtn(
              color: Color(0xffE8CC5C),
              onTap: () {
                tapSign(multiList);
              },
              path: 'multisig.png',
            ),
            CommonText(
              'multisig'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
      ],
    );
  }
}

class ReadonlyService extends StatelessWidget {
  List<MultiSignWallet> get multiList => getList();
  @override
  Widget build(BuildContext context) {
    double gap = Global.langCode == 'en' ? 20 : 30;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(walletCodePage);
              },
              path: 'send.png',
              color: CustomColor.primary,
            ),
            CommonText(
              'rec'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
        SizedBox(
          width: gap,
        ),
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(mesMakePage, arguments: {'origin': mainPage});
              },
              path: 'make-w.png',
              color: Color(0xff5C8BCB),
            ),
            CommonText(
              'mesMake'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
        SizedBox(
          width: gap,
        ),
        Column(
          children: [
            IconBtn(
              color: Color(0xff67C23A),
              onTap: () {
                Get.toNamed(mesPushPage);
              },
              path: 'push-w.png',
            ),
            CommonText(
              'mesPush'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
        SizedBox(
          width: gap,
        ),
        Column(
          children: [
            IconBtn(
              color: Color(0xffE8CC5C),
              onTap: () {
                tapSign(multiList);
              },
              path: 'multisig.png',
            ),
            CommonText(
              'multisig'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
      ],
    );
  }
}

class OfflineService extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(walletCodePage);
              },
              path: 'send.png',
              color: CustomColor.primary,
            ),
            CommonText(
              'rec'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
        SizedBox(
          width: 30,
        ),
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(signIndexPage);
              },
              path: 'multisig.png',
              color: Color(0xff5C8BCB),
            ),
            CommonText(
              'signBtn'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
      ],
    );
  }
}
