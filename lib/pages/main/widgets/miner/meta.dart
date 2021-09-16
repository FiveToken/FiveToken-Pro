import 'package:fil/index.dart';

class MinerField {
  String label;
  String key;
  Formatter formatter;
  MinerField({this.formatter, this.label, this.key});
}

String balanceFormatter(dynamic value) {
  value = value as String;
  if (value == '0') {
    return '0';
  }
  return double.parse(value).toStringAsFixed(2) + ' FIL';
}

List<MinerField> getMetaList() {
  return <MinerField>[
    MinerField(label: 'metaLock'.tr, key: 'lock'),
    MinerField(label: 'metaPledge'.tr, key: 'pledge'),
    MinerField(label: 'metaDeposit'.tr, key: 'deposit'),
    MinerField(label: 'metaAvailable'.tr, key: 'available'),
    MinerField(label: 'metaQuality'.tr, key: 'qualityPower'),
    MinerField(label: 'metaRewards'.tr, key: 'rewards'),
  ];
}

class MetaBoard extends StatelessWidget {
  final MinerMeta dataSource;
  final String owner;
  MetaBoard(this.dataSource, this.owner);
  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    var _metaList = getMetaList();
    var data = dataSource.toJson();
    for (var i = 0; i < _metaList.length; i++) {
      var meta = _metaList[i];
      var label = meta.label;
      var key = meta.key;
      double width = (i % 2 == 0) ? 0.5 : 0;
      var res = '';
      var value = data[key];
      if (key == 'qualityPower') {
        res = unitConversion(value, 2);
      } else {
        res = balanceFormatter(value);
      }
      var border = Border(
          right: BorderSide(color: Colors.grey[200], width: width),
          top: BorderSide(color: Colors.grey[200], width: .5));
      list.add(MinerDisplayField(
        label: label,
        value: res,
        border: border,
      ));
    }
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          child:
              Image(fit: BoxFit.fill, image: AssetImage('images/miner-bg.png')),
          height: 170,
        ),
        Positioned(
            child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    'balance'.tr,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    balanceFormatter(dataSource.balance),
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FButton(
                    text: 'withdraw'.tr,
                    color: Color(0xff5CC1CB),
                    clickEffect: true,
                    padding: EdgeInsets.fromLTRB(40, 8, 40, 8),
                    cornerStyle: FCornerStyle.round,
                    corner: FCorner.all(20),
                    style: TextStyle(color: Colors.white),
                    onPressed: () {
                      Get.toNamed(mesMakePage, arguments: {
                        'type': MessageType.MinerManage,
                        'from': owner,
                        'to': $store.wal.address,
                        'balannce': dataSource.balance
                      });
                    },
                    // gradient: LinearGradient(
                    //     colors: [Color(0xff2b98ff), Color(0xff5CC1CB)])
                  ),
                ],
              ),
            ),
            Wrap(
              children: list,
            ),
          ]),
        ))
      ],
    );
  }
}

class MinerDisplayField extends StatelessWidget {
  final String label;
  final String value;
  final String tips;
  final BoxBorder border;
  MinerDisplayField({this.label, this.value, this.border, this.tips = ''});
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .5,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(border: border),
        height: 60,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              Visibility(
                child: GestureDetector(
                  child: Icon(Icons.warning),
                ),
                visible: tips != '',
              )
            ],
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600),
          )
        ]),
      ),
    );
  }
}
typedef String Formatter(dynamic value);
