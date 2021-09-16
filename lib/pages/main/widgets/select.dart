import 'package:fil/index.dart';

class WalletSelect extends StatefulWidget {
  final double bottom;
  final SingleParamCallback<Wallet> onTap;
  final bool more;
  final String filterType;
  final double footerHeight; 
  WalletSelect({this.bottom, this.onTap, this.more = false, this.filterType,this.footerHeight=0});
  @override
  State<StatefulWidget> createState() {
    return WalletSelectState();
  }
}

class WalletSelectState extends State<WalletSelect> {
  String selectType = 'all';

  void handleSelect(String type) {
    setState(() {
      selectType = type;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.filterType != null) {
      this.selectType = widget.filterType;
    }
  }

  List<WalletTypeInfo> get typeList {
    if (!Global.onlineMode) {
      return [
        WalletTypeInfo(label: 'all'.tr, type: 'all'),
        WalletTypeInfo(label: 'off'.tr, type: 'hd'),
      ];
    }
    var all = [
      WalletTypeInfo(label: 'all'.tr, type: 'all'),
      WalletTypeInfo(label: 'hd'.tr, type: 'hd'),
      WalletTypeInfo(label: 'readonly'.tr, type: 'readonly'),
      WalletTypeInfo(label: 'miner'.tr, type: 'miner'),
    ];
    if (widget.filterType != null) {
      return all.where((item) => item.type == widget.filterType).toList();
    }
    return [
      WalletTypeInfo(label: 'all'.tr, type: 'all'),
      WalletTypeInfo(label: 'hd'.tr, type: 'hd'),
      WalletTypeInfo(label: 'readonly'.tr, type: 'readonly'),
      WalletTypeInfo(label: 'miner'.tr, type: 'miner'),
    ];
  }

  List<TypedList> get list {
    var hdList = TypedList(
        title: Global.onlineMode ? 'hdW'.tr : 'offlineW'.tr,
        type: 'hd',
        list: []);
    var readonlyList =
        TypedList(title: 'readonlyW'.tr, type: 'readonly', list: []);
    var minerList = TypedList(title: 'minerW'.tr, type: 'miner', list: []);
    OpenedBox.addressInsance.values
        .where((wal) => wal.addrWithNet != '')
        .forEach((wal) {
      if (wal.walletType == 0) {
        if (wal.readonly == 1) {
          readonlyList.list.add(wal);
        } else {
          hdList.list.add(wal);
        }
      } else if (wal.walletType == 2) {
        minerList.list.add(wal);
      }
    });
    var all = <TypedList>[]
      ..addAll([hdList])
      ..addAll([readonlyList])
      ..addAll([minerList]);
    // all = all.where((item) => item.list.length > 0).toList();
    switch (selectType) {
      case 'all':
        return all;
      case 'hd':
        return [hdList];
      case 'readonly':
        return [readonlyList];
      case 'miner':
        return [minerList];
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: List.generate(typeList.length, (index) {
            var t = typeList[index];
            return TypeItem(
              label: t.label,
              active: selectType == t.type,
              onTap: () {
                handleSelect(t.type);
              },
            );
          }),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
            child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: widget.bottom ?? 20),
                child: Column(
                  children: List.generate(list.length, (index) {
                    var item = list[index];
                    return Padding(
                      child: TypedListWidget(
                        list: item.list,
                        title: item.title,
                        onTap: widget.onTap,
                        more: widget.more,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(
              height: widget.footerHeight,
            )
          ],
        )),
      ],
    );
  }
}

class WalletTypeInfo {
  String label;
  String type;
  WalletTypeInfo({this.label, this.type});
}

class TypeItem extends StatelessWidget {
  final String label;
  final bool active;
  final Noop onTap;
  final double width;
  TypeItem({this.label, this.active = false, this.onTap, this.width});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        child: Row(
          children: [
            Container(
              width: width ?? 70,
              child: CommonText(
                label,
                size: 14,
                align: TextAlign.right,
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Container(
              width: 2,
              height: 12,
              color: active ? CustomColor.primary : Colors.transparent,
            )
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ),
      ),
      onTap: onTap,
    );
  }
}

class TypedList {
  String title;
  String type;
  List<Wallet> list;
  TypedList({this.title, this.type, this.list});
}

class TypedListWidget extends StatelessWidget {
  final String title;
  final List<Wallet> list;
  final SingleParamCallback<Wallet> onTap;
  final bool more;
  TypedListWidget({this.title, this.list, this.onTap, this.more = false});
  @override
  Widget build(BuildContext context) {
    if (list.length == 0) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        CommonText(title),
        SizedBox(
          height: 5,
        ),
        Column(
          children: List.generate(list.length, (index) {
            var wallet = list[index];
            return Column(
              children: [
                GestureDetector(
                  child: Stack(
                    children: [
                      Positioned(
                          child: Container(
                        height: 70,
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText.white(wallet.label, size: 16),
                            CommonText.white(
                              dotString(str: wallet.address),
                              size: 12,
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            borderRadius: CustomRadius.b8,
                            color: wallet.addrWithNet == $store.wal.addrWithNet
                                ? CustomColor.primary
                                : Color(0xff8297B0)),
                      )),
                      Positioned(
                          right: 10,
                          bottom: 5,
                          child: Visibility(
                            child: Image(
                              width: 20,
                              image: AssetImage('images/more.png'),
                            ),
                            visible: more,
                          ))
                    ],
                  ),
                  onTap: () {
                    onTap(wallet);
                  },
                ),
                Visibility(
                    visible: index != list.length - 1,
                    child: SizedBox(
                      height: 10,
                    ))
              ],
            );
          }),
        )
      ],
    );
  }
}
