
import 'package:day/day.dart';
import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MultiMessageList extends StatefulWidget {
  final String address;
  MultiMessageList(this.address);
  @override
  State<StatefulWidget> createState() {
    return MultiMessageListState();
  }
}

class MultiMessageListState extends State<MultiMessageList> with RouteAware {
  List<StoreMultiMessage> messageList =
      OpenedBox.multiMesInsance.values.toList();
  var box = OpenedBox.multiInsance;
  Map<String, List<StoreMultiMessage>> mesMap = {};
  var mesBox = OpenedBox.multiMesInsance;
  bool isProposal = true;
  RefreshController controller = RefreshController(initialRefresh: false);
  MultiSignWallet get wallet {
    return singleStoreController.multiWal;
  }

  @override
  void initState() {
    super.initState();
    getBalance();
    fresh();
    setList();
    getMessagesAfterFirstCompletedMessage();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setList();
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
  }

  @override
  void didUpdateWidget(covariant MultiMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      setList();
    }
  }

  void getBalance() async {
    var info = await getMultiInfo(wallet.id);
    if (info.signerMap != null) {
      wallet.balance = info.balance;
      box.put(wallet.id, wallet);
      singleStoreController.changeMultiWalletBalance(wallet.balance);
    }
  }

  void setList() {
    var list = getWalletSortedMessages();
    setState(() {
      messageList = list;
    });
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

  void onRefresh() async {
    getBalance();
    await getMessagesAfterFirstCompletedMessage();
    controller.refreshCompleted();
  }

  List<StoreMultiMessage> get filterList {
    var filterList = messageList.where((msg) {
      var type = isProposal ? 'proposal' : 'approval';

      var flag = msg.type == type;
      return flag;
    }).toList();
    return filterList;
  }

  MessageSearchMeta getMeta(String type) {
    var filters = messageList.where((mes) => mes.type == type).toList();
    var direction = 'down';
    num time;
    if (filters.isNotEmpty) {
      for (var i = 0; i < filters.length; i++) {
        var msg = filters[i];
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
      time = filters.last.blockTime - 3600 * 24;
      direction = 'down';
    }
    return MessageSearchMeta(time: time, direction: direction);
  }

  Future<List<StoreMultiMessage>> getMessagesByType(
      {String type = 'proposal'}) {
    var meta = getMeta(type);
    return getMessages(
        count: 80,
        direction: meta.direction,
        time: meta.time,
        method: type == 'proposal' ? 'Propose' : 'Approve');
  }

  Future getMessagesAfterFirstCompletedMessage() async {
    var future1 = () => getMessagesByType();
    var future2 = () => getMessagesByType(type: 'approval');
    Future.wait([future1(), future2()]).then((resList) {
      var propsals = resList[0];

      var approvals = resList[1];
      if (propsals.isNotEmpty || approvals.isNotEmpty) {
        if (mounted) {
          setState(() {
            messageList = getWalletSortedMessages();
          });
        }
      }
    });
  }

  Future<List<StoreMultiMessage>> getMessages(
      {num time,
      String direction = 'up',
      num count = 80,
      String method = 'Propose'}) async {
    try {
      var type = method == 'Propose' ? 'proposal' : 'approval';
      var res = await getMultiMessageList(
          address: wallet.id,
          direction: direction,
          time: time ?? getSecondSinceEpoch(),
          count: count,
          method: method);
      if (res.isNotEmpty) {
        var messages = res.map((e) {
          var mes = StoreMultiMessage.fromJson(e);
          var cache = mesBox.get(mes.signedCid);
          if (cache != null&&cache.msigTo!=null) {
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
    return noData
        ? NoData()
        : Column(
            children: [
              Column(
                children: [],
              ),
              Expanded(
                  child: SmartRefresher(
                onRefresh: onRefresh,
                controller: controller,
                enablePullUp: false,
                header: WaterDropHeader(
                  waterDropColor: CustomColor.primary,
                  complete: Text('finish'.tr),
                ),
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
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
                            // var args = message.args;
                            // if (args != null && args != 'null') {
                            //   var decodeArgs = jsonDecode(args);
                            //   if (decodeArgs != null &&
                            //       (decodeArgs is Map) &&
                            //       decodeArgs['AmountRequested'] != null) {
                            //     message.value = decodeArgs['AmountRequested'];
                            //   }
                            // }
                            return MultiMessageItem(message);
                          }),
                        )
                      ],
                    );
                  },
                  itemCount: keys.length,
                ),
              ))
            ],
          );
  }
}

class MultiMessageItem extends StatelessWidget {
  final StoreMultiMessage mes;
  MultiMessageItem(this.mes);
  bool get isSend {
    return mes.from == singleStoreController.wal.address;
  }

  bool get fail {
    return mes.exitCode != 0;
  }

  bool get pending {
    return mes.pending == 1;
  }

  String get addr {
    return '${'to'.tr} ${dotString(str: mes.msigTo ?? '')}';
  }

  String get value {
    var v = atto2Fil(mes.msigValue);
    return '${mes.msigValue != null ? v : '0'}' + ' FIL';
  }

  bool get isApproval {
    return mes.methodName == 'Approve' || mes.type == 'approval';
  }

  Color get color {
    int n;
    if (pending) {
      n = 0xffE8CC5C;
    } else if (fail) {
      n = 0xffB4B5B7;
    } else {
      if (isApproval) {
        n = 0xff5C8BCB;
      } else {
        n = 0xff5CC1CB;
      }
    }
    return Color(n);
  }

  String get path {
    if (pending) {
      return 'pending.png';
    } else if (fail) {
      return 'fail.png';
    } else {
      if (isApproval) {
        return 'approval.png';
      } else {
        return 'proposal.png';
      }
    }
  }

  String get label {
    //String prefix = 'Approve';
    if (isApproval) {
      if (pending) {
        return 'approvalPending'.tr;
      } else {
        if (mes.exitCode != 0) {
          return 'approvalFail'.tr;
        } else {
          return 'approvalSucc'.tr;
        }
      }
    } else {
      //prefix = 'Propose';
      if (pending) {
        return 'proposalPending'.tr;
      } else {
        if (mes.exitCode != 0) {
          return 'proposalFail'.tr;
        } else {
          if (mes.msigApproved != mes.msigRequired) {
            return 'waitApprove'.tr;
          } else {
            return 'proposalSucc'.tr;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        var needApprove = mes.msigApproved != mes.msigRequired &&
            mes.from != singleStoreController.wal.addrWithNet;
        Get.toNamed(multiProposalDetailPage, arguments: {
          'msg': mes,
          'needApprove': needApprove,
          'type': mes.type,
          'label': label
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          children: [
            IconBtn(
              size: 32,
              color: color,
              path: path,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Layout.colStart([
                CommonText.main(
                  label,
                  size: 15,
                ),
                CommonText.grey(addr, size: 10),
              ]),
            ),
            CommonText(
              value,
              size: 15,
              color: CustomColor.primary,
              weight: FontWeight.w500,
            )
          ],
        ),
      ),
    );
  }
}

class MessageSearchMeta {
  String direction;
  num time;
  MessageSearchMeta({this.direction = '', this.time = 0});
}
