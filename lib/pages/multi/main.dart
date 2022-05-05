import 'dart:async';
import 'package:day/day.dart';
import 'package:fbutton/fbutton.dart';
import 'package:fil/bloc/multi/multi_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/time.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/event/index.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/noop.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/pages/message/method.dart';
import 'package:fil/pages/multi/widgets/multiMessageItem.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/style/index.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/fresh.dart';
import 'package:fil/widgets/icon.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../app.dart';

/// display balance and messages of the multi-sig wallet
class MultiMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiMainPageState();
  }
}

/// page of multi main
class MultiMainPageState extends State<MultiMainPage> with RouteAware {
  Map<String, List<CacheMultiMessage>> mesMap = {};
  Worker worker;
  StreamSubscription sub;
  int signerNonce;
  RefreshController rc;

  List<int> tabsList = [MultiTabs.proposal, MultiTabs.collection];

  @override
  void initState() {
    super.initState();
    worker = ever($store.multiWallet, (wal) {
      BlocProvider.of<MultiBloc>(_context)..add(getWalletSortedMessagesEvent(MultiTabs.proposal));
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
    BlocProvider.of<MultiBloc>(_context)..add(getWalletSortedMessagesEvent(MultiTabs.proposal));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
    worker.dispose();
    sub.cancel();
  }

  Future onRefresh(BuildContext context) async {
    BlocProvider.of<MultiBloc>(context)
      ..add(getLatestMessagesEvent(MultiTabs.proposal))
      ..add(getMultiInfoEvent($store.multiWal.id));
  }

  Future onLoading(BuildContext context, int selectType, String mid) async {
    BlocProvider.of<MultiBloc>(context).add(getMessagesBeforeLastCompletedMessageEvent(selectType, mid, 'up'));
  }

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MultiBloc()
          ..add(getWalletSortedMessagesEvent(MultiTabs.proposal)),
        child: BlocBuilder<MultiBloc, MultiState>(builder: (context, state) {
          _context = context;
          mesMap = {};
          var filterList = state.messageList;
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
                      title: $store.multiWal.addressWithNet,
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
              onRefresh: () {
                onRefresh(context);
              },
              enablePullUp: state.enablePullUp,
              refreshKey: multiMainPage,
              onLoading: () {
                onLoading(context, state.selectType, state.mid);
              },
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
                                                showCustomError(
                                                    'nameTooLong'.tr);
                                                return;
                                              }
                                              var wallet = $store.multiWal;
                                              wallet.label = v;
                                              OpenedBox.multiInsance.put(
                                                  wallet.addressWithNet,
                                                  wallet);
                                              $store.changeMultiWalletName(v);
                                              unFocusOf(context);
                                              Get.back();
                                              showCustomToast(
                                                  'changeNameSucc'.tr);
                                            },
                                          ));
                                    },
                                  )
                                ]),
                                SizedBox(
                                  height: 10,
                                ),
                                Obx(() => CommonText(
                                      formatFil($store.multiWal.balance,
                                          size: 6),
                                      size: 30,
                                      weight: FontWeight.w800,
                                    )),
                                SizedBox(
                                  height: 12,
                                ),
                                Obx(() => CommonText(
                                      getMarketPrice($store.multiWal.balance,
                                          Global.price),
                                    )),
                                SizedBox(
                                  height: 18,
                                ),
                                Obx(() => CopyAddress(
                                    $store.multiWal.addressWithNet)),
                                SizedBox(
                                  height: 18,
                                ),
                                MultiWalletBtns(),
                                Spacer(),
                                Row(
                                  children:
                                      List.generate(tabsList.length, (index) {
                                    return Expanded(
                                        child: GestureDetector(
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: tabsList[index] ==
                                                            state.selectType
                                                        ? CustomColor.primary
                                                        : Colors.transparent,
                                                    width: 2))),
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: CommonText(
                                          <String>[
                                            'propose'.tr,
                                            'receive'.tr,
                                          ][index],
                                          size: 16,
                                          color: tabsList[index] ==
                                                  state.selectType
                                              ? CustomColor.primary
                                              : Colors.black,
                                          weight: tabsList[index] ==
                                                  state.selectType
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      onTap: () {
                                        BlocProvider.of<MultiBloc>(context).add(
                                            updateSelectTypeEvent(tabsList[index]));
                                        BlocProvider.of<MultiBloc>(context).add(
                                            getWalletSortedMessagesEvent(tabsList[index]));
                                        BlocProvider.of<MultiBloc>(context).add(
                                            getLatestMessagesEvent(tabsList[index]));
                                      },
                                    ));
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
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
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
                                    threshold: $store.multiWal.threshold,
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
          ;
        }));
  }
}

class MultiWalletSelect extends StatelessWidget {
  final Noop onTap;
  MultiWalletSelect({this.onTap});
  List<MultiSignWallet> get list {
    return OpenedBox.multiInsance.values
        .where((wal) =>
            wal.status == 1 && wal.signers.contains($store.wal.addressWithNet))
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
                    if (wallet.addressWithNet !=
                        $store.multiWal.addressWithNet) {
                      Global.store.setString(
                          'activeMultiAddress', wallet.addressWithNet);
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
                          wallet.addressWithNet,
                          size: 12,
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        borderRadius: CustomRadius.b8,
                        color: wallet.addressWithNet ==
                                $store.multiWal.addressWithNet
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

class MultiWalletBtns extends StatelessWidget {
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
