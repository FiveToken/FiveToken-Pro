import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/drawer.dart';
import 'package:fil/pages/main/miner.dart';
import 'package:fil/pages/main/offline.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/main/widgets/select.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((value) async {
      if (value != null && isValidAddress(value)) {
        Get.toNamed(filTransferPage, arguments: {'to': value});
      }
    });
  }

  String getTitle(Wallet wal) {
    var type = wal.walletType;
    if (!Global.onlineMode) {
      return 'offlineW'.tr;
    } else {
      if (type == 2) {
        return 'minerW'.tr;
      } else {
        var readonly = wal.readonly == 1;
        if (readonly) {
          return 'readonlyW'.tr;
        } else {
          return 'hdW'.tr;
        }
      }
    }
  }

  Widget get child {
    if ($store.wal.walletType == 2) {
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
                      $store.setWallet(wallet);
                      Global.store
                          .setString('activeWalletAddress', wallet.addrWithNet);
                      Get.back();
                      setState(() {});
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
                    Obx(() => $store.wal.walletType != 2 && Global.onlineMode
                        ? $store.wal.readonly != 1
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
                                        '0',
                                        '2',
                                        '3',
                                        '16',
                                        '21',
                                        '23'
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
            body: Obx(() => $store.wal.walletType == 2
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