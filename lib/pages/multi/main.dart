import 'package:fil/index.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/main/widgets/select.dart';
import 'package:fil/pages/multi/widgets/multiMessageList.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MultiMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiMainPageState();
  }
}

class MultiMainPageState extends State<MultiMainPage> {
  MultiSignWallet wallet = singleStoreController.multiWal;
  RefreshController controller = RefreshController();
  var box = OpenedBox.multiInsance;
  var mesBox = OpenedBox.multiMesInsance;
  List<StoreMultiMessage> messageList = [];
  String tab = 'Proposal';
  GlobalKey<MultiMessageListState> key = GlobalKey();
  void getBalance() async {
    var info = await getMultiInfo(wallet.id);
    if (info.signerMap != null) {
      wallet.balance = info.balance;
      box.put(wallet.id, wallet);
      singleStoreController.changeMultiWalletBalance(wallet.balance);
    }
  }

  @override
  void initState() {
    super.initState();
    getBalance();
    fresh();
    setList();
    getMessagesAfterFirstCompletedMessage();
  }

  bool get isProposal {
    return tab == 'Proposal';
  }

  void handleTabChange(String t) async {
    setState(() {
      tab = t;
      messageList = getWalletSortedMessages();
    });
    Future.delayed(Duration.zero).then((value) {
      if (filterList.isEmpty) {
        getMessagesAfterFirstCompletedMessage();
        //controller.requestRefresh();
      }
    });
  }

  void setList() {
    var list = getWalletSortedMessages();
    setState(() {
      messageList = list;
    });
  }

  List<StoreMultiMessage> get filterList {
    var filterList = messageList.where((msg) {
      var type = isProposal ? 'proposal' : 'approval';

      var flag = msg.type == type;
      return flag;
    }).toList();
    return filterList;
  }

  Future getMessagesAfterFirstCompletedMessage() async {
    var list = filterList;
    var direction = 'down';
    num time;
    if (list.isNotEmpty) {
      for (var i = 0; i < list.length; i++) {
        var msg = list[i];
        if (msg.pending == 0) {
          time = msg.blockTime - 3600 * 24;
          break;
        }
      }
    } else {
      direction = 'up';
      time = getSecondSinceEpoch();
    }

    if (time == null) {
      time = list.last.blockTime - 3600 * 24;
      direction = 'down';
    }
    var lis = await getMessages(time: time, direction: direction, count: 80);
    if (lis.isNotEmpty) {
      if (mounted) {
        setState(() {
          messageList = getWalletSortedMessages();
        });
      }
    }
  }

  void fresh() {
    Map<String, StoreMultiMessage> map = {};
    mesBox.values.where((value) {
      var now = getSecondSinceEpoch();
      var mes = value;
      return mes.pending == 1 && (now - mes.blockTime > 3600 * 2);
    }).forEach((e) {
      var mes = e;
      mes.pending = 0;
      mes.exitCode = -1;
      map[mes.signedCid] = mes;
    });
    mesBox.putAll(map);
  }

  Future<List<StoreMultiMessage>> getMessages(
      {num time, String direction = 'up', num count = 80}) async {
    try {
      var type = isProposal ? 'proposal' : 'approval';
      var res = await getMultiMessageList(
          address: wallet.id,
          direction: direction,
          time: time ?? getSecondSinceEpoch(),
          count: count,
          method: isProposal ? 'Propose' : 'Approve');
      if (res.isNotEmpty) {
        var messages = res.map((e) {
          var mes = StoreMultiMessage.fromJson(e);
          var cache = mesBox.get(mes.signedCid);
          if (cache != null) {
            mes.msigValue = cache.msigValue;
            mes.msigTo = cache.msigTo;
            mes.proposalCid = cache.proposalCid;
          }
          mes.pending = 0;
          mes.type = type;
          return mes;
        });
        messages.forEach((mes) {
          var cid = mes.signedCid;
          if (mes.exitCode != -1) {
            mesBox.put(cid, mes);
          }
        });
        return messages.toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  List<StoreMultiMessage> getWalletSortedMessages() {
    var list = <StoreMultiMessage>[];
    var address = this.wallet.id;
    var robustAddress = this.wallet.robustAddress;
    mesBox.values.forEach((element) {
      //var type = isProposal ? 'proposal' : 'approval';
      var message = element;
      if (message.to == address || message.to == robustAddress) {
        list.add(message);
      }
    });
    list.sort((a, b) {
      if (a.blockTime != null && b.blockTime != null) {
        return b.blockTime.compareTo(a.blockTime);
      } else {
        return -1;
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(NavHeight),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: NavElevation,
          title: Obx(() => DropdownFButton(
                title: singleStoreController.multiWal.addrWithNet,
                onTap: () {
                  showCustomModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: CustomRadius.top),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                      CommonText('selectMulti'.tr,
                                          color: Colors.white),
                                      SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(child: MultiWalletSelect())
                              ],
                            ),
                            constraints: BoxConstraints(maxHeight: 800));
                      });
                },
              )),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: IconNavBack,
            alignment: NavLeadingAlign,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          Layout.rowCenter([
            Obx(
              () => CommonText(
                singleStoreController.multiWal.label,
                size: 16,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            GestureDetector(
              child: Image(
                image: AssetImage('images/edit.png'),
                width: 16,
              ),
              onTap: () {
                var ctrl = TextEditingController();
                ctrl.text = singleStoreController.multiWal.label;
                showCustomDialog(
                    context,
                    ChangeNameDialog(
                      controller: ctrl,
                      onTap: () {
                        var v = ctrl.text;
                        v = v.trim();
                        if (v == "") {
                          showCustomError('enterName'.tr);
                          return;
                        }
                        if (v.length > 20) {
                          showCustomError('nameTooLong'.tr);
                          return;
                        }
                        var wallet = singleStoreController.multiWal;
                        wallet.label = v;
                        OpenedBox.multiInsance.put(wallet.addrWithNet, wallet);
                        singleStoreController.changeMultiWalletName(v);
                        unFocusOf(context);
                        Get.back();
                        showCustomToast('changeNameSucc'.tr);
                      },
                    ));
              },
            )
          ]),
          SizedBox(
            height: 10,
          ),
          Obx(() => CommonText(
                formatFil(
                  singleStoreController.multiWal.balance,
                ),
                size: 30,
                weight: FontWeight.w800,
              )),
          SizedBox(
            height: 12,
          ),
          Obx(() => CommonText(
                getMarketPrice(
                    singleStoreController.multiWal.balance, Global.price?.rate),
              )),
          SizedBox(
            height: 18,
          ),
          Obx(() => CopyAddress(singleStoreController.multiWal.addrWithNet)),
          SizedBox(
            height: 18,
          ),
          MultiWalletService(),
          SizedBox(
            height: 35,
          ),
          Expanded(
              child: Obx(() =>
                  MultiMessageList(singleStoreController.multiWal.addrWithNet)))
        ],
      ),
    );
  }
}

class MultiWalletSelect extends StatelessWidget {
  List<MultiSignWallet> get list {
    return OpenedBox.multiInsance.values
        .where((wal) =>
            wal.status == 1 &&
            wal.signers.contains(singleStoreController.wal.addrWithNet))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TypeItem(
              width: 80,
              label: 'multisig'.tr,
              active: true,
              onTap: () {},
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: CommonText('multiWallet'.tr),
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                  ),
                  Column(
                    children: List.generate(list.length, (index) {
                      var wallet = list[index];
                      return GestureDetector(
                        onTap: () {
                          if (wallet.addrWithNet !=
                              singleStoreController.multiWal.addrWithNet) {
                            Global.store.setString(
                                'activeMultiAddress', wallet.addrWithNet);
                            singleStoreController.setMultiWallet(wallet);
                          }
                          Get.back();
                        },
                        child: Container(
                          height: 70,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CommonText.white(wallet.label, size: 16),
                              CommonText.white(
                                wallet.addrWithNet,
                                size: 12,
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              borderRadius: CustomRadius.b8,
                              color: wallet.addrWithNet ==
                                      singleStoreController.multiWal.addrWithNet
                                  ? CustomColor.primary
                                  : Color(0xff8297B0)),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ))
          ],
        )),
        Container(
          //padding: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]))),
          child: Row(
            children: [
              Expanded(
                  child: FButton(
                height: 50,
                color: Colors.white,
                image: Icon(Icons.add),
                alignment: Alignment.center,
                text: 'createMulti'.tr,
                onPressed: () {
                  Get.back();
                  Get.toNamed(multiCreatePage);
                },
              )),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[200],
              ),
              Expanded(
                  child: FButton(
                height: 50,
                image: Icon(Icons.add),
                text: 'importMulti'.tr,
                color: Colors.white,
                onPressed: () {
                  Get.back();
                  Get.toNamed(multiImportPage);
                },
                alignment: Alignment.center,
              )),
            ],
          ),
        )
      ],
    );
  }
}

class MultiWalletService extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(multiDetailPage);
              },
              path: 'info.png',
              color: Color(0xff67C23A),
            ),
            CommonText(
              'multiInfo'.tr,
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
                Get.toNamed(multiProposalPage);
              },
              path: 'proposal.png',
              color: CustomColor.primary,
            ),
            CommonText(
              'propose'.tr,
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
              color: Color(0xff5C8BCB),
              onTap: () {
                Get.toNamed(multiApprovalPage);
              },
              path: 'approval.png',
            ),
            CommonText(
              'approve'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
      ],
    );
  }
}
