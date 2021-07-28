import 'package:fil/index.dart';

typedef void SelectCallback(Wallet wallet);
typedef bool WalletFilter(Wallet wallet);
void showWalletListSelector(BuildContext context, SelectCallback callback,
    {WalletFilter filter}) {
  var box = Hive.box<Wallet>(addressBox);
  var addressList = <Wallet>[];
  var otherList = <Wallet>[];
  var allList = <Wallet>[];
  box.values.forEach((element) {
    if (element.walletType == 0) {
      otherList.add(element);
    }
    if (element.walletType == 1) {
      addressList.add(element);
    }
  });
  allList..addAll(addressList)..addAll(otherList);
  if (filter != null) {
    allList = allList.where((element) => filter(element)).toList();
  }
  var children = allList
      .map((e) => Container(
            height: 35,
            child: FlatButton(
              minWidth: double.infinity,
              child: CommonText(
                '${e.label} (${dotString(str: e.addr)})',
                weight: FontWeight.w300,
              ),
              onPressed: () {
                callback(e);
                Get.back();
              },
            ),
            //alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.grey[100],
            ))),
          ))
      .toList();
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (
        BuildContext context,
      ) {
        return SizedBox(
          height: 250,
          child: Center(
              child: Column(
            children: [
              Container(
                child: Text(
                  'select'.tr,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              Expanded(
                  child: ListView(
                children: children,
              ))
            ],
          )),
        );
      });
}
