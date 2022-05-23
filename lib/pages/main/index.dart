import 'package:fbutton/fbutton.dart';
import 'package:fil/common/back.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/event/index.dart';
import 'package:fil/models/noop.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/main/drawer.dart';
import 'package:fil/pages/main/miner.dart';
import 'package:fil/pages/main/offline.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/main/widgets/select.dart';
import 'package:fil/pages/message/make.dart';
import 'package:fil/pages/message/method.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/style/index.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_root_jailbreak/flutter_root_jailbreak.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    checkRoot();
  }

  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((value) async {
      if (value != null && isValidAddress(value as String)) {
        Get.toNamed(filTransferPage, arguments: {'to': value});
      }
    });
  }

  String getTitle(Wallet wal) {
    var type = wal.walletType;
    if (!Global.onlineMode) {
      return 'offlineW'.tr;
    } else {
      if (type == WalletsType.miner) {
        return 'minerWallet'.tr;
      } else {
        if (wal.readonly == 1) {
          return 'readonlyWallet'.tr;
        } else {
          return 'commonAccount'.tr;
        }
      }
    }
  }

  Future<void> checkRoot() async {
    bool isRoot = await isRooted();
    if (isRoot) {
      rootDialog();
    }
  }

  void rootDialog() {
    showCustomDialog(
        context,
        Column(
          children: [
            CommonTitle(
              'rootTitle'.tr,
              showDelete: true,
            ),
            Container(
              child: Text(
                'rootTips'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              padding: EdgeInsets.symmetric(horizontal: 57, vertical: 28),
            ),
            Divider(
              height: 1,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: CommonText(
                  'know'.tr,
                  color: CustomColor.primary,
                ),
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              onTap: () {
                Get.back();
              },
            ),
          ],
        ));
  }

  Future<bool> isRooted() async {
    try {
      bool result = Global.platform == 'android'
          ? await FlutterRootJailbreak.isRooted
          : await FlutterRootJailbreak.isJailBroken;
      return result;
    } catch (e) {
      return false;
    }
  }

  Widget get child {
    if ($store.wal.walletType == WalletsType.miner) {
      return MinerAddressStats();
    } else {
      if (Global.onlineMode) {
        return OnlineWallet();
      } else {
        return OfflineWallet();
      }
    }
  }

  void tapDropdown() {
    showCustomModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: context,
        builder: (BuildContext context) {
          return ConstrainedBox(
              child: Column(
                children: [
                  Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            topLeft: Radius.circular(8)),
                        color: CustomColor.primary),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          child: Image(
                            width: 20,
                            image: AssetImage('images/close.png'),
                          ),
                          onTap: () {
                            Get.back();
                          },
                        ),
                        CommonText('selectWallet'.tr, color: Colors.white),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.toNamed(walletSelectPage);
                          },
                          child: CommonText('manage'.tr, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Expanded(child: WalletSelect(
                    onTap: (Wallet wallet) {
                      if (wallet.addr != $store.addr) {
                        $store.setWallet(wallet);
                        Global.store.setString(
                            'activeWalletAddress', wallet.addressWithNet);
                        //
                        Global.eventBus.fire(AccountChangeEvent());
                      }
                      Get.back();
                    },
                  ))
                ],
              ),
              constraints: BoxConstraints(maxHeight: 800));
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: PreferredSize(
                child: AppBar(
                  actions: [
                    Obx(() => $store.wal.walletType != WalletsType.miner &&
                            Global.onlineMode
                        ? $store.wal.readonly == 0
                            ? Padding(
                                child: GestureDetector(
                                    onTap: handleScan,
                                    child: Image(
                                      width: 20,
                                      image: AssetImage('images/scan.png'),
                                    )),
                                padding: EdgeInsets.only(right: 10),
                              )
                            : Container()
                        : Global.onlineMode
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  showMethodSelector(
                                      context: context,
                                      title: 'opOption'.tr,
                                      methods: [
                                        '16',
                                        '23',
                                        '3',
                                        '21',
                                      ],
                                      onTap: (method) {
                                        Get.toNamed(mesMakePage, arguments: {
                                          'type': MessageType.MinerManage,
                                          'from': '',
                                          'method': method,
                                          'to': $store.wal.address
                                        });
                                      });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Center(
                                    child: CommonText('minerManage'.tr),
                                  ),
                                ),
                              )
                            : Container()),
                  ],
                  backgroundColor: Color(FColorWhite),
                  elevation: NavElevation,
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: IconList,
                        alignment: NavLeadingAlign,
                      );
                    },
                  ),
                  title: Obx(() => DropdownFButton(
                        title: getTitle($store.wal),
                        onTap: tapDropdown,
                      )),
                  centerTitle: true,
                ),
                preferredSize: Size.fromHeight(NavHeight)),
            drawer: Drawer(
              child: DrawerBody(
                onTap: tapDropdown,
              ),
            ),
            backgroundColor: Colors.white,
            body: Obx(() => $store.wal.walletType == WalletsType.miner
                ? MinerAddressStats()
                : Global.onlineMode
                    ? OnlineWallet()
                    : OfflineWallet())),
        onWillPop: () async {
          AndroidBackTop.backDeskTop();
          return false;
        });
  }
}

class DropdownFButton extends StatelessWidget {
  final String title;
  final Noop onTap;
  DropdownFButton({this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return FButton(
      image: Icon(
        Icons.arrow_drop_down,
        color: Color(0xffcccccc),
      ),
      imageMargin: 0,
      onPressed: onTap,
      imageAlignment: ImageAlignment.right,
      text: ' ' + title,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      style: TextStyle(color: Colors.black, fontSize: 16),
      corner: FCorner.all(10),
      strokeWidth: 1,
      strokeColor: Color(0xffcccccc),
    );
  }
}

class IconBtn extends StatelessWidget {
  final Noop onTap;
  final String path;
  final Color color;
  final double size;
  IconBtn({this.onTap, this.path, this.color, this.size = 40});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size / 5),
        margin: EdgeInsets.only(bottom: 5),
        child: Image(image: AssetImage('images/$path')),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: color),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}

class NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: (Get.height - 500) / 2,
        ),
        Image(width: 65, image: AssetImage('images/record.png')),
        SizedBox(
          height: 25,
        ),
        CommonText(
          'noData'.tr,
          color: CustomColor.grey,
        ),
        SizedBox(
          height: 170,
        ),
      ],
    );
  }
}
