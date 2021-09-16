import 'package:day/day.dart';
import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/widgets/service.dart';
import 'package:fil/widgets/dialog.dart';
import 'messageItem.dart';

class OnlineWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OnlineWalletState();
  }
}

class OnlineWalletState extends State<OnlineWallet> with RouteAware {
  final TextEditingController controller = TextEditingController();
  var box = Hive.box<Wallet>(addressBox);
  var multiBox = OpenedBox.multiInsance;
  var mesBox = OpenedBox.messageInsance;
  List<MultiSignWallet> multiList = [];
  FilPrice price = FilPrice();
  List<StoreMessage> messageList = [];
  Map<String, List<StoreMessage>> mesMap = {};
  Box<Nonce> nonceBoxInstance = OpenedBox.nonceInsance;
  bool enablePullDown = true;
  bool enablePullUp = true;
  num currentNonce;
  StreamSubscription sub;
  Worker worker;
  int selectType = 0;
  void getPrice() async {
    var res = await getFilPrice();
    Global.price = res;
    if (res.cny != 0) {
      if (mounted) {
        setState(() {
          this.price = res;
        });
      }
    }
  }

  double get rate {
    var lang = Global.langCode;
    lang = 'en';
    return lang == 'en' ? price.usd : price.cny;
  }

  @override
  void initState() {
    super.initState();
    getPrice();
    var isCreate = false;
    if (Get.arguments != null && Get.arguments['create'] != null) {
      isCreate = Get.arguments['create'] as bool;
    }
    var show = Get.arguments != null && isCreate == true;
    if (show) {
      showChangeNameDialog();
    }
    messageList = getWalletSortedMessages();
    nextTick(() {
      fireEvent();
    });
    sub = Global.eventBus.on<AppStateChangeEvent>().listen((event) {
      fireEvent();
    });
    worker = ever($store.wallet, (Wallet wal) {
      if (wal.walletType != 2) {
        setState(() {
          messageList = getWalletSortedMessages();
          enablePullUp = false;
        });
        nextTick(() {
          fireEvent();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  void fireEvent() {
    Global.eventBus.fire(ShouldRefreshEvent(refreshKey: mainPage));
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
    sub.cancel();
    worker.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {
      messageList = getWalletSortedMessages();
    });
  }

  void showChangeNameDialog() {
    Future.delayed(Duration.zero).then((value) {
      controller.text = $store.wal.label;
      showCustomDialog(
          context,
          Container(
            child: Column(
              children: [
                CommonTitle(
                  'makeName'.tr,
                  showDelete: true,
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Field(
                          //autofocus: true,
                          controller: controller,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        height: 1,
                      ),
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: CommonText(
                            'sure'.tr,
                            color: CustomColor.primary,
                          ),
                        ),
                        onTap: () {
                          var v = controller.text;
                          v = v.trim();
                          if (v == "") {
                            showCustomError('enterName'.tr);
                            return;
                          }
                          if (v.length > 20) {
                            showCustomError('nameTooLong'.tr);
                            return;
                          }
                          var wallet = $store.wal;
                          wallet.label = v;
                          box.put(wallet.address, wallet);
                          $store.changeWalletName(v);
                          unFocusOf(context);
                          Get.back();
                          showCustomToast('createSucc'.tr);
                        },
                        behavior: HitTestBehavior.opaque,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(top: 20),
                )
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xfff8f8f8),
            ),
          ));
    });
  }

  Future<void> updateBalance() async {
    var wal = $store.wal;
    var res = await getBalance($store.wal.addrWithNet);
    if (res.nonce != -1) {}
    if (res.balance != wal.balance) {
      wal.balance = res.balance;
      $store.changeWalletBalance(res.balance);
      this.currentNonce = res.nonce;
      OpenedBox.addressInsance.put(wal.address, wal);
    }
  }

  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((value) async {
      if (value != null && isValidAddress(value)) {
        Get.toNamed(filTransferPage, arguments: {'to': value});
      }
    });
  }

  Future getLatestMessage() async {
    var resList = await getMessages(
        time: getSecondSinceEpoch(), direction: 'down', count: 40);
    if (resList.isNotEmpty && mounted) {
      var list=getWalletSortedMessages();
      setState(() {
        messageList = list;
        enablePullUp = resList.length >= 40;
      });
    }
  }

  /// load messages before
  Future getMessagesBeforeLastCompletedMessage() async {
    var list = messageList;
    num time;
    if (list.isNotEmpty) {
      for (var i = list.length - 1; i > 0; i--) {
        var current = list[i];
        if (current.pending != 1 && current.blockTime != null) {
          time = current.blockTime + 10;
          break;
        }
      }
    }
    var lis = await getMessages(time: time, direction: 'up');
    if (mounted) {
      if (lis.isNotEmpty) {
        setState(() {
          messageList = getWalletSortedMessages();
          enablePullUp = lis.length >= 40;
        });
      } else {
        setState(() {
          enablePullUp = false;
        });
      }
    }
  }

  List<StoreMessage> getWalletSortedMessages() {
    var list = <StoreMessage>[];
    var address = $store.wal.address;
    mesBox.values.forEach((element) {
      var message = element;
      if (message.from == address || message.to == address) {
        list.add(message);
      }
    });
    list.sort((a, b) {
      if (a.blockTime != null && b.blockTime != null) {
        return b.blockTime.compareTo(a.blockTime);
      } else {
        return 1;
      }
    });

    return list;
  }

  Future<List<StoreMessage>> getMessages(
      {num time, String direction = 'up', num count = 40}) async {
    try {
      var res = await getMessageList(
          address: $store.wal.address, time: time, count: count);
      if (res.isNotEmpty) {
        var messages = res.map((e) {
          var mes = StoreMessage.fromJson(e);
          mes.pending = 0;
          mes.owner = $store.wal.address;
          return mes;
        }).toList();

        /// if the current nonce of the wallet is biggger than the nonce of the message,
        /// message was either packaged or discarded
        /// delete it from local db
        var nonce = this.currentNonce;
        var pendingList = messageList.where((mes) => mes.pending == 1).toList();

        if (pendingList.isNotEmpty) {
          for (var k = 0; k < pendingList.length; k++) {
            var mes = pendingList[k];
            if (nonce != null && mes.nonce < nonce) {
              await mesBox.delete(mes.signedCid);
            }
          }
        }
        if (direction == 'down') {
          var completeKeys = messageList
              .where((mes) => mes.pending == 0)
              .map((mes) => mes.signedCid);
          await mesBox.deleteAll(completeKeys);
        }
        for (var i = 0; i < messages.length; i++) {
          var m = messages[i];
          if (FilecoinMethod.validMethods.contains(m.methodName)) {
            await mesBox.put(m.signedCid, m);
          }
        }

        /// if there is a pending message which send for create multi-sig wallet,
        /// get the detail info of the multi-sig wallet from this message
        if (messages.where((mes) => mes.to == FilecoinAccount.f01).isNotEmpty) {
          checkCreateMessages();
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

  Future onRefresh() async {
    updateBalance();
    await getLatestMessage();
  }

  Future onLoading() async {
    await getMessagesBeforeLastCompletedMessage();
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
            'all'.tr,
            'rec'.tr,
            'send'.tr,
          ][type],
          size: 16,
          color: active ? CustomColor.primary : Colors.black,
          weight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          selectType = type;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    mesMap = {};
    var filterList = messageList.where((mes) {
      switch (selectType) {
        case 0:
          return true;
        case 1:
          return mes.to == $store.wal.addrWithNet;
        case 2:
          return mes.from == $store.wal.addrWithNet;
        default:
          return true;
      }
    });
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
    return CustomRefreshWidget(
        onLoading: onLoading,
        enablePullUp: enablePullUp,
        initRefresh: false,
        refreshKey: mainPage,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          Obx(
                            () => CommonText(
                              $store.wal.label,
                              size: 16,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Obx(
                            () => CommonText(
                              formatFil($store.wal.balance),
                              size: 30,
                              weight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Obx(() => CommonText(
                              getMarketPrice($store.wal.balance, rate))),
                          SizedBox(
                            height: 15,
                          ),
                          Obx(() => CopyAddress($store.wal.addrWithNet)),
                          SizedBox(
                            height: 15,
                          ),
                          Obx(() => $store.wal.readonly == 0
                              ? HdService()
                              : ReadonlyService()),
                          Spacer(),
                          Row(
                            children: List.generate([0, 1, 2].length, (index) {
                              return Expanded(
                                  child: genMethodSelectItem(
                                      type: index,
                                      active: index == selectType));
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                    maxHeight: 280,
                    minHeight: 280)),
            noData
                ? SliverToBoxAdapter(child: NoData())
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
                              var args = message.args;
                              if (args != null && args != 'null') {
                                var decodeArgs = jsonDecode(args);
                                if (decodeArgs != null &&
                                    (decodeArgs is Map) &&
                                    decodeArgs['AmountRequested'] != null) {
                                  message.value = decodeArgs['AmountRequested'];
                                }
                              }
                              return MessageItem(message);
                            }),
                          )
                        ],
                      );
                    }, childCount: keys.length),
                  )
          ],
        ),
        onRefresh: onRefresh);
  }
}

String getMarketPrice(String balance, double rate) {
  if (rate == null) {
    rate = 0;
  }
  try {
    var b = double.parse(balance) / pow(10, 18);
    var code = 'en';
    var unit = code == 'en' ? '\$' : '¥';
    return rate == 0
        ? '--'
        : ' $unit ${formatDouble((rate * b).toStringAsFixed(2))}';
  } catch (e) {
    print(e);
    return '--';
  }
}

class CopyAddress extends StatelessWidget {
  final String address;
  CopyAddress(this.address);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 25,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: CommonText(
            dotString(str: address),
            size: 14,
            color: Color(0xffB4B5B7),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Color(0xfff8f8f8)),
        ),
        SizedBox(
          width: 14,
        ),
        GestureDetector(
          onTap: () {
            copyText(address);
            showCustomToast('copyAddr'.tr);
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: CustomColor.primary,
                borderRadius: BorderRadius.circular(5)),
            child: Image(
                fit: BoxFit.fitWidth,
                width: 17,
                height: 17,
                image: AssetImage('images/copy-w.png')),
          ),
        )
      ],
    );
  }
}

class ChangeNameDialog extends StatelessWidget {
  final TextEditingController controller;
  final Noop onTap;
  ChangeNameDialog({this.controller, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CommonTitle(
            'makeName'.tr,
            showDelete: true,
          ),
          Container(
            child: Column(
              children: [
                Container(
                  child: Field(
                    //autofocus: true,
                    controller: controller,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  height: 1,
                ),
                GestureDetector(
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CommonText(
                      'sure'.tr,
                      color: CustomColor.primary,
                    ),
                  ),
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                ),
              ],
            ),
            padding: EdgeInsets.only(top: 20),
          )
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xfff8f8f8),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  SliverDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

Future checkCreateMessages() async {
  var box = OpenedBox.multiInsance;
  var l = box.values.where((wal) => wal.status == 0).toList();
  if (l.isNotEmpty) {
    for (var i = 0; i < l.length; i++) {
      var wal = l[i];
      var detail = await getMessageDetail(StoreMessage(signedCid: wal.cid));
      if (detail.height != null) {
        var code = detail.exitCode;
        var copy = MultiSignWallet(
            cid: wal.cid,
            signers: wal.signers,
            label: wal.label,
            blockTime: detail.blockTime,
            threshold: wal.threshold);
        if (code == 0 || code == null) {
          copy.status = 1;
          var returns = detail.returns;
          if (returns != null && returns['IDAddress'] != null) {
            var res = await getMultiInfo(returns['IDAddress']);
            if (res.signerMap != null && res.signerMap.keys.isNotEmpty) {
              box.delete(wal.cid);
              copy.id = returns['IDAddress'];
              copy.signerMap = res.signerMap;
              copy.robustAddress = res.robustAddress;
              box.put(returns['IDAddress'], copy);
            }
          }
        } else {
          wal.status = -1;
          box.put(wal.cid, wal);
        }
      } else {
        var time = wal.blockTime;
        var now = getSecondSinceEpoch();
        if (now - time > 3600 * 2) {
          wal.status = -1;
          box.put(wal.cid, wal);
        }
      }
    }
  }
}
