import 'package:bls/bls.dart';
import 'package:fil/api/update.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:fil/bloc/check/check_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/wallet.dart';
import 'package:flotus/flotus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'mne.dart';

/// check if user has remembered the mne
class MneCheckPage extends StatefulWidget {
  @override
  State createState() => MneCheckPageState();
}

/// page of check mne
class MneCheckPageState extends State<MneCheckPage> {
  List<String> unSelectedList = [];
  List<String> selectedList = [];
  final String mne = Get.arguments['mne'] as String;
  @override
  void initState() {
    super.initState();
    var list = mne.split(' ');
    list.shuffle();
    unSelectedList = list;
  }

  void handleSelect(BuildContext context, num index) {
    BlocProvider.of<CheckBloc>(context).add(UpdateEvent(type: index.toInt()));
    // var rm = unSelectedList.removeAt(index.toInt());
    // selectedList.add(rm);
  }

  void handleRemove(BuildContext context, num index) {
    BlocProvider.of<CheckBloc>(context).add(DeleteEvent(type: index.toInt()));
    // var rm = selectedList.removeAt(index.toInt());
    // unSelectedList.add(rm);
  }

  String get mneCk {
    return genCKBase64(mne);
  }

  void createWallet(BuildContext context, String type) async {
    try {
      String signType = SignSecp;
      String pk = '';
      String ck = '';
      if (type == '1') {
        ck = genCKBase64(mne);
        pk = await Flotus.secpPrivateToPublic(ck: ck);
      } else {
        var key = bip39.mnemonicToSeed(mne);
        signType = SignBls;
        ck = await Bls.ckgen(num: key.join(""));
        pk = await Bls.pkgen(num: ck);
      }
      String address = await Flotus.genAddress(pk: pk, t: signType);
      address = Global.netPrefix + address.substring(1);
      var exist = OpenedBox.addressInsance.containsKey(address);
      if (exist) {
        showCustomError('errorExist'.tr);
        return;
      }
      Wallet activeWallet = Wallet(
          ck: ck,
          address: address,
          label: 'FIL',
          readonly: 0,
          mne: mne,
          walletType: 0,
          type: type);
      Get.toNamed(passwordSetPage,
          arguments: {'wallet': activeWallet, 'create': true});
      addOperation('create_mne');
    } catch (e) {
      showCustomError('checkMneFail'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CheckBloc()..add(SetCheckEvent(unSelectedList: unSelectedList)),
      child: BlocBuilder<CheckBloc, CheckState>(builder: (context, state) {
        return CommonScaffold(
          onPressed: () {
            var str = state.selectedList.join(' ');
            if (str != mne || state.selectedList.length < 12) {
              showCustomError('wrongMne'.tr);
              return;
            }
            showWalletSelector(context, (String type) {
              createWallet(context, type);
            });
          },
          footerText: 'next'.tr,
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        'checkMne'.tr,
                        size: 14,
                        weight: FontWeight.w500,
                      ),
                      CommonText(
                        'clickMne'.tr,
                        size: 14,
                        color: Color(0xffB4B5B7),
                      ),
                    ],
                  ),
                  width: double.infinity,
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 200),
                    child: GridView.count(
                      padding: EdgeInsets.all(10),
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      childAspectRatio: 2.1,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      children:
                          List.generate(state.selectedList.length, (index) {
                        return MneItem(
                          remove: true,
                          label: state.selectedList[index],
                          onTap: () {
                            handleRemove(context, index);
                          },
                        );
                      }),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GridView.count(
                  crossAxisCount: 3,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  childAspectRatio: 2.1,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: List.generate(state.unSelectedList.length, (index) {
                    return MneItem(
                      label: state.unSelectedList[index],
                      bg: CustomColor.primary,
                      onTap: () {
                        handleSelect(context, index);
                      },
                    );
                  }),
                )
              ],
            ),
            padding: EdgeInsets.fromLTRB(12, 20, 12, 100),
          ),
        );
      }),
    );
  }
}
