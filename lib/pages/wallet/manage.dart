import 'package:fil/common/global.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// rename,export mne,export private key, reset pass
class WalletManagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletManagePageState();
  }
}

/// page of wallet manage
class WalletManagePageState extends State<WalletManagePage> {
  Wallet wallet;
  TextEditingController controller = TextEditingController();
  var box = OpenedBox.addressInsance;
  void handleDelete() async {
    var wal = Global.cacheWallet;
    var keys = OpenedBox.messageInsance.values
        .where((mes) => mes.owner == wal.addr)
        .map((mes) => mes.signedCid)
        .toList();
    OpenedBox.messageInsance.deleteAll(keys);
    await box.delete(wal.address);

    var list = box.values.where((wal) => wal.address != '').toList();
    if (list.isEmpty) {
      Global.store.remove('activeWalletAddress');
      $store.setWallet(Wallet());
      Get.offAllNamed(initLangPage);
    } else {
      if (wal.addressWithNet == $store.wal.addressWithNet) {
        var w = list.where((wal) => wal.addressWithNet != '').toList()[0];
        $store.setWallet(w);
        Global.store.setString('activeWalletAddress', w.addressWithNet);
      }
      Get.back();
      showCustomToast('deleteSucc'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    wallet = Global.cacheWallet;
    var label = wallet.label;
    var mne = wallet.mne;
    var addr = wallet.address;
    var hasMne = wallet.readonly == 0 && mne != null && mne != '';
    var items = [
      CardItem(
          label: 'pkExport'.tr,
          onTap: () {
            showPassDialog(context, (String pass) async {
              var address = wallet.addressWithNet;
              var sk = await decryptSodium(wallet.skKek, address, pass);
              Get.toNamed(walletPrivatekey, arguments: {'pk': sk});
            }, from: wallet);
          }),
      CardItem(
          label: 'mneExport'.tr,
          onTap: () {
            showPassDialog(context, (String pass) async {
              try {
                var address = wallet.addressWithNet;
                var mne = await decryptSodium(wallet.mne, address, pass);
                Get.toNamed(walletMnePage, arguments: {'mne': mne});
              } catch (e) {
                showCustomError(e.toString());
                print(e);
              }
            }, from: wallet);
          }),
    ];
    if (!hasMne) {
      items.removeAt(1);
    }
    return CommonScaffold(
      title: 'manageWallet'.tr,
      footerColor: CustomColor.red,
      footerText: 'delete'.tr,
      onPressed: () {
        showDeleteDialog(context,
            title: 'deleteAddr'.tr, content: 'confirmDelete'.tr, onDelete: () {
          handleDelete();
        });
      },
      body: Padding(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            TapCard(
              items: [
                CardItem(
                  label: 'walletAddress'.tr,
                  onTap: () {},
                  append: CommonText(
                    dotString(str: addr),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            TapCard(
              items: [
                CardItem(
                  label: 'walletName'.tr,
                  onTap: () {
                    controller.text = label;
                    showCustomDialog(
                        context,
                        Container(
                          child: Column(
                            children: [
                              CommonTitle(
                                'changeWalletName'.tr,
                                showDelete: true,
                              ),
                              Padding(
                                child: Field(
                                  autofocus: true,
                                  controller: controller,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 20),
                              ),
                              Divider(
                                height: 1,
                              ),
                              Container(
                                height: 40,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        child: CommonText(
                                          'cancel'.tr,
                                        ),
                                        alignment: Alignment.center,
                                      ),
                                      onTap: () {
                                        Get.back();
                                      },
                                    )),
                                    Container(
                                      width: .2,
                                      color: CustomColor.grey,
                                    ),
                                    Expanded(
                                        child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        child: CommonText(
                                          'sure'.tr,
                                          color: CustomColor.primary,
                                        ),
                                        alignment: Alignment.center,
                                      ),
                                      onTap: () {
                                        var newLabel = controller.text.trim();
                                        if (newLabel == '') {
                                          showCustomError('enterName'.tr);
                                          return;
                                        }
                                        if (newLabel.length > 20) {
                                          showCustomError('nameTooLong'.tr);
                                          return;
                                        }
                                        wallet.label = newLabel;
                                        OpenedBox.addressInsance
                                            .put(addr, wallet);
                                        if (wallet.addr == $store.addr) {
                                          $store.changeWalletName(newLabel);
                                        }
                                        setState(() {});
                                        Get.back();
                                        showCustomToast('changeNameSucc'.tr);
                                      },
                                    )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        color: CustomColor.bgGrey);
                  },
                  append: Row(
                    children: [
                      CommonText(
                        label,
                      ),
                      ImageAr
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
                visible: wallet.readonly == 0,
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    TapCard(
                      items: items,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TapCard(
                      items: [
                        CardItem(
                          label: 'changePass'.tr,
                          onTap: () {
                            Get.toNamed(passwordResetPage).then((value) {
                              setState(() {});
                            });
                          },
                        )
                      ],
                    ),
                  ],
                ))
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
