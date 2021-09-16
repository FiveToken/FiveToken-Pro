import 'package:day/day.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/multi/widgets/multiMessageList.dart';

/// display balance and messages of the multi-sig wallet
class MultiMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiMainPageState();
  }
}

class MultiMainPageState extends State<MultiMainPage> with RouteAware {
  MultiSignWallet get wallet => $store.multiWal;
  var box = OpenedBox.multiInsance;
  var mesBox = OpenedBox.multiMesInsance;
  List<StoreMultiMessage> messageList = [];
  // GlobalKey<MultiMessageListState> key = GlobalKey();
  Map<String, List<StoreMultiMessage>> mesMap = {};
  Worker worker;
  StreamSubscription sub;
  int signerNonce;
  bool enablePullUp = false;
  void getBalance() async {
    var info = await getMultiInfo(wallet.id);
    if (info.signerMap != null) {
      if (wallet.balance != info.balance) {
        wallet.balance = info.balance;
        box.put(wallet.id, wallet);
        $store.changeMultiWalletBalance(wallet.balance);
      }
    }
  }

  Future getSignerNonce() async {
    var nonce = await getNonce($store.wal.addrWithNet);
    if (nonce != -1) {
      this.signerNonce = nonce;
    }
  }

  @override
  void initState() {
    super.initState();
    messageList = getWalletSortedMessages();
    worker = ever($store.multiWallet, (wal) {
      setState(() {
        messageList = getWalletSortedMessages();
        enablePullUp = false;
      });
      nextTick(() {
        fireEvent();
      });
    });
    nextTick(() {
      fireEvent();
    });
    sub = Global.eventBus.on<AppStateChangeEvent>().listen((event) {
      fireEvent();
    });
  }

  void fireEvent() {
    Global.eventBus.fire(ShouldRefreshEvent(refreshKey: multiMainPage));
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {
      messageList = getWalletSortedMessages();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
    worker.dispose();
    sub.cancel();
  }

  Future onRefresh() async {
    getBalance();
    await getLatestMessage();
  }

  Future<List<StoreMultiMessage>> getMessagesByType(
      {String type = 'proposal', num time, String direction}) {
    return getMessages(
        count: 40,
        direction: direction,
        time: time,
        method: type == 'proposal' ? 'Propose' : 'Approve');
  }

  Future getLatestMessage() async {
    var now = getSecondSinceEpoch();
    var future1 = () => getMessagesByType(time: now, direction: 'down');
    var future2 =
        () => getMessagesByType(type: 'approval', time: now, direction: 'down');
    Future.wait([future1(), future2()]).then((resList) async {
      var propsals = resList[0];
      var approvals = resList[1];
      if (propsals.isNotEmpty || approvals.isNotEmpty) {
        var pendingList = messageList.where((mes) => mes.pending == 1);
        if (pendingList.isNotEmpty) {
          await getSignerNonce();
          if (signerNonce != null) {
            var keys = pendingList
                .where((mes) => mes.nonce < signerNonce)
                .map((mes) => mes.signedCid);
            await mesBox.deleteAll(keys);
          }
        }
        if (propsals.isNotEmpty) {
          var completeKeys = messageList
              .where((mes) => mes.pending == 0 && mes.type == 'proposal')
              .map((mes) => mes.signedCid);
          await mesBox.deleteAll(completeKeys);
          await putList(propsals);
        }
        if (approvals.isNotEmpty) {
          var completeKeys = messageList
              .where((mes) => mes.pending == 0 && mes.type == 'approval')
              .map((mes) => mes.signedCid);
          await mesBox.deleteAll(completeKeys);
          await putList(approvals);
        }
        if (mounted) {
          var list = getWalletSortedMessages();
          setState(() {
            messageList = list;
            enablePullUp = approvals.length >= 40 || propsals.length > 40;
          });
        }
      }
    });
  }

  Future putList(List<StoreMultiMessage> messages) async {
    for (var mes in messages) {
      var cid = mes.signedCid;
      if (mes.exitCode != -1) {
        await mesBox.put(cid, mes);
      }
    }
  }

  num getTime(List<StoreMultiMessage> list) {
    num time = getSecondSinceEpoch();
    if (list.isNotEmpty) {
      for (var i = list.length - 1; i > 0; i--) {
        var current = list[i];
        if (current.pending != 1 && current.blockTime != null) {
          time = current.blockTime + 10;
          break;
        }
      }
    }
    return time;
  }

  Future getMessagesBeforeLastCompletedMessage() async {
    var proposalList =
        messageList.where((mes) => mes.type == 'proposal').toList();
    var approvalList =
        messageList.where((mes) => mes.type == 'approval').toList();
    var future1 =
        () => getMessagesByType(time: getTime(proposalList), direction: 'up');
    var future2 = () => getMessagesByType(
        type: 'approval', time: getTime(approvalList), direction: 'up');
    Future.wait([future1(), future2()]).then((resList) async {
      var propsals = resList[0];
      var approvals = resList[1];
      if (propsals.isNotEmpty || approvals.isNotEmpty) {
        await Future.wait([putList(propsals), putList(approvals)]);
        setState(() {
          messageList = getWalletSortedMessages();
          enablePullUp = propsals.length >= 40 || approvals.length >= 40;
        });
      }
    });
  }

  Future<List<StoreMultiMessage>> getMessages(
      {num time,
      String direction = 'up',
      num count = 40,
      String method = 'Propose'}) async {
    try {
      var type = method == 'Propose' ? 'proposal' : 'approval';
      var res = await getMultiMessageList(
          address: wallet.id, time: time, count: count, method: method);
      if (res.isNotEmpty) {
        var messages = res.map((e) {
          var mes = StoreMultiMessage.fromJson(e);
          mes.pending = 0;
          mes.type = type;
          return mes;
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
    var address = wallet.id;
    var robustAddress = wallet.robustAddress;
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
    mesMap = {};
    var filterList = messageList;
    var today = Day();
    var formatStr = 'YYYY-MM-DD';
    var todayStr = today.format(formatStr);
    var yestoday = today.subtract(1, 'd') as Day;
    var yestodayStr = yestoday.format(formatStr);
    filterList.forEach((mes) {
      var time = formatTimeByStr(mes.blockTime, str: formatStr);

      var item = mesMap[time];
      if (item == null) {
        mesMap[time] = [];
      }
      mesMap[time].add(mes);
    });
    var keys = mesMap.keys.toList();
    var noData = filterList.isEmpty;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(NavHeight),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: NavElevation,
          title: Obx(() => DropdownFButton(
                title: $store.multiWal.addrWithNet,
                onTap: () {
                  showMultiWalletSelector(context, null);
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
      body: CustomRefreshWidget(
        onRefresh: onRefresh,
        enablePullUp: enablePullUp,
        refreshKey: multiMainPage,
        onLoading: getMessagesBeforeLastCompletedMessage,
        initRefresh: false,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverDelegate(
                  minHeight: 270,
                  maxHeight: 270,
                  child: Container(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          Layout.rowCenter([
                            Obx(
                              () => CommonText(
                                $store.multiWal.label,
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
                                ctrl.text = $store.multiWal.label;
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
                                        var wallet = $store.multiWal;
                                        wallet.label = v;
                                        OpenedBox.multiInsance
                                            .put(wallet.addrWithNet, wallet);
                                        $store.changeMultiWalletName(v);
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
                                  $store.multiWal.balance,
                                ),
                                size: 30,
                                weight: FontWeight.w800,
                              )),
                          SizedBox(
                            height: 12,
                          ),
                          Obx(() => CommonText(
                                getMarketPrice($store.multiWal.balance,
                                    Global.price?.rate),
                              )),
                          SizedBox(
                            height: 18,
                          ),
                          Obx(() => CopyAddress($store.multiWal.addrWithNet)),
                          SizedBox(
                            height: 18,
                          ),
                          MultiWalletService(),
                        ],
                      ),
                      color: Colors.white)),
            ),
            noData
                ? SliverToBoxAdapter(
                    child: NoData(),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                    var date = keys[index];
                    var l = mesMap[date];
                    if (date == yestodayStr) {
                      date = 'yestoday'.tr;
                    } else if (date == todayStr) {
                      date = 'today'.tr;
                    }
                    return Column(
                      children: [
                        Container(
                          height: 20,
                          padding: EdgeInsets.only(left: 12),
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: CommonText(
                            date,
                            size: 10,
                            color: CustomColor.grey,
                          ),
                          color: CustomColor.bgGrey,
                        ),
                        Column(
                          children: List.generate(l.length, (i) {
                            var message = l[i];
                            return MultiMessageItem(message);
                          }),
                        )
                      ],
                    );
                  }, childCount: keys.length))
          ],
        ),
      ),
    );
  }
}

class MultiWalletSelect extends StatelessWidget {
  final Noop onTap;
  MultiWalletSelect({this.onTap});
  List<MultiSignWallet> get list {
    return OpenedBox.multiInsance.values
        .where((wal) =>
            wal.status == 1 && wal.signers.contains($store.wal.addrWithNet))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(list.length, (index) {
                var wallet = list[index];
                return GestureDetector(
                  onTap: () {
                    if (wallet.addrWithNet != $store.multiWal.addrWithNet) {
                      Global.store
                          .setString('activeMultiAddress', wallet.addrWithNet);
                      $store.setMultiWallet(wallet);
                    }
                    Get.back();
                    if (onTap != null) {
                      onTap();
                    }
                  },
                  child: Container(
                    height: 70,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        color: wallet.addrWithNet == $store.multiWal.addrWithNet
                            ? CustomColor.primary
                            : Color(0xff8297B0)),
                  ),
                );
              })),
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
    ));
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
                // Get.toNamed(multiProposalPage);
                showMethodSelector(
                    title: 'proposalType'.tr,
                    context: context,
                    methods: ['0', '3', '16', '21', '23'],
                    onTap: (method) {
                      Get.toNamed(multiProposalPage,
                          arguments: {'method': method});
                    });
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

void showMultiWalletSelector(BuildContext context, Noop onTap) {
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
                      CommonText('selectMulti'.tr, color: Colors.white),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: MultiWalletSelect(
                  onTap: onTap,
                ))
              ],
            ),
            constraints: BoxConstraints(maxHeight: 800));
      });
}
