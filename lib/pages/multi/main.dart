import 'package:day/day.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/multi/widgets/multiMessageItem.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  var mesBox = OpenedBox.multiProposeInstance;
  List<CacheMultiMessage> messageList = [];
  Map<String, List<CacheMultiMessage>> mesMap = {};
  Worker worker;
  StreamSubscription sub;
  int signerNonce;
  bool enablePullUp = false;
  RefreshController rc;
  int selectType = 0;
  void getBalance() async {
    try {
      var info = await Global.provider.getMultiInfo(wallet.id);
      if (wallet.balance != info.balance) {
        wallet.balance = info.balance;
        box.put(wallet.id, wallet);
        $store.changeMultiWalletBalance(wallet.balance);
      }
    } catch (e) {
      print(e);
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
        rc.requestRefresh();
      });
    });
    sub = Global.eventBus.on<AppStateChangeEvent>().listen((event) {
      rc.requestRefresh();
    });
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
    await getLatestMessages();
  }

  Future getLatestMessages() async {
    var resList = await getMessages(
      direction: 'down',
    );

    if (resList.isNotEmpty && mounted) {
      var list = getWalletSortedMessages();
      setState(() {
        messageList = list;
        enablePullUp = resList.length >= 20;
      });
    }
  }

  Future getMessagesBeforeLastCompletedMessage() async {
    var completeList = messageList.where((mes) => mes.mid != '').toList();
    var mid = completeList.last.mid;
    var lis = await getMessages(mid: mid);
    if (mounted) {
      if (lis.isNotEmpty) {
        setState(() {
          messageList = getWalletSortedMessages();
          enablePullUp = lis.length >= 20;
        });
      } else {
        setState(() {
          enablePullUp = false;
        });
      }
    }
  }

  Widget genMethodSelectItem({Noop onTap, bool active, int type = 0}) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: active ? CustomColor.primary : Colors.transparent,
                    width: 2))),
        padding: EdgeInsets.only(bottom: 8),
        child: CommonText(
          <String>[
            'propose'.tr,
            'receive'.tr,
          ][type],
          size: 16,
          color: active ? CustomColor.primary : Colors.black,
          weight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          selectType = type;
          messageList = getWalletSortedMessages(type: type);
        });
        getLatestMessages();
      },
    );
  }

  Future<List<CacheMultiMessage>> getMessages(
      {String direction = 'up', String mid = ''}) async {
    try {
      var handle = selectType == 0
          ? Global.provider.getMultiMessageList
          : Global.provider.getMultiReceiveMessages;
      var list = await handle(actor: wallet.id, direction: direction, mid: mid);
      if (list.isNotEmpty) {
        var maxNonce = 0;
        var messages = list.map((e) {
          var mes = CacheMultiMessage.fromJson(e);
          mes.pending = 0;
          mes.owner = $store.addr;
          mes.type = selectType;
          if (mes.nonce != null &&
              mes.nonce > maxNonce &&
              mes.from == $store.addr) {
            maxNonce = mes.nonce;
          }
          return mes;
        }).toList();

        var pendingList = messageList.where((mes) => mes.pending == 1).toList();
        if (pendingList.isNotEmpty) {
          for (var k = 0; k < pendingList.length; k++) {
            var mes = pendingList[k];
            if (mes.nonce <= maxNonce && mes.owner == $store.addr) {
              await mesBox.delete(mes.cid);
            }
          }
        }
        if (direction == 'down') {
          var completeKeys = messageList
              .where((mes) => mes.pending == 0)
              .map((mes) => mes.cid);
          await mesBox.deleteAll(completeKeys);
        }
        for (var i = 0; i < messages.length; i++) {
          var m = messages[i];
          var approves = OpenedBox.multiApproveInstance.values
              .where((apr) => apr.proposeCid == m.cid)
              .toList();
          if (m.approves.isNotEmpty && approves.isNotEmpty) {
            List<String> deleteKeys = [];
            m.approves.forEach((apr) {
              var from = apr.from;
              var relatedApproves =
                  approves.where((ap) => ap.from == from).toList();
              relatedApproves.forEach((ap) async {
                if (apr.nonce != null && ap.nonce != null) {
                  if (apr.nonce >= ap.nonce) {
                    deleteKeys.add(ap.cid);
                  }
                } else {
                  deleteKeys.add(ap.cid);
                }
              });
            });
            if (deleteKeys.isNotEmpty) {
              await OpenedBox.multiApproveInstance.deleteAll(deleteKeys);
            }
          }
          OpenedBox.multiProposeInstance.put(m.cid, m);
        }
        return messages.toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  List<CacheMultiMessage> getWalletSortedMessages({int type}) {
    if (type == null) {
      type = selectType;
    }
    var list = <CacheMultiMessage>[];
    var resList = <CacheMultiMessage>[];
    var address = wallet.id;
    var robustAddress = wallet.robustAddress;
    list = mesBox.values
        .where((message) =>
            (message.to == address || message.to == robustAddress) &&
            message.type == type)
        .toList();
    var pendingList = <CacheMultiMessage>[];
    var completeList = <CacheMultiMessage>[];
    list.forEach((mes) {
      if (mes.pending == 0) {
        completeList.add(mes);
      } else {
        pendingList.add(mes);
      }
    });
    pendingList.sort((a, b) {
      if (a.nonce != null && b.nonce != null) {
        return b.blockTime.compareTo(a.blockTime);
      } else {
        return 1;
      }
    });
    completeList.sort((a, b) {
      if (a.nonce != null && b.nonce != null) {
        return b.blockTime.compareTo(a.blockTime);
      } else {
        return 1;
      }
    });
    resList..addAll(pendingList)..addAll(completeList);
    return resList;
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
        onInit: (rc) {
          this.rc = rc;
        },
        initRefresh: true,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverDelegate(
                  minHeight: 280,
                  maxHeight: 280,
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
                                  size: 6
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
                          Spacer(),
                          Row(
                            children: List.generate([0, 1].length, (index) {
                              return Expanded(
                                  child: genMethodSelectItem(
                                      type: index,
                                      active: index == selectType));
                            }).toList(),
                          )
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
                            return MultiMessageItem(
                              mes: message,
                              threshold: wallet.threshold,
                            );
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
                    methods: [
                      '0',
                      '16',
                      '23',
                      '3',
                      '21',
                    ],
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
        // SizedBox(
        //   width: 30,
        // ),
        // Column(
        //   children: [
        //     IconBtn(
        //       color: Color(0xff5C8BCB),
        //       onTap: () {
        //         Get.toNamed(multiApprovalPage);
        //       },
        //       path: 'approval.png',
        //     ),
        //     CommonText(
        //       'approve'.tr,
        //       color: Color(0xffB4B5B7),
        //       size: 10,
        //     )
        //   ],
        // ),
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
