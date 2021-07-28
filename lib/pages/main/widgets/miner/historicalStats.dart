import 'package:fil/index.dart';

typedef String Formatter(dynamic value);

class MinerField {
  String label;
  String key;
  Formatter formatter;
  MinerField({this.formatter, this.label, this.key});
}

List<MinerField> getYestodayList() {
  return <MinerField>[
    MinerField(
      label: 'yesBlock'.tr,
      key: 'block',
      formatter: (value) =>
          (double.parse(value) / pow(10, 18)).toStringAsFixed(2) + 'FIL',
    ),
    MinerField(key: 'total', label: '', formatter: (value) => ''),
    MinerField(
        label: 'yesWorker'.tr, key: 'worker', formatter: balanceFormatter),
    MinerField(
        label: 'yesController'.tr,
        key: 'controller',
        formatter: balanceFormatter),
    MinerField(
        label: 'yesSector'.tr,
        key: 'sector',
        formatter: (dynamic v) => unitConversion(v, 2)),
    MinerField(
        label: 'yesPledge'.tr, key: 'pledge', formatter: balanceFormatter),
  ];
}

class HistoricalStats extends StatelessWidget {
  final MinerHistoricalStats dataSource;
  HistoricalStats(this.dataSource);
  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    var data = dataSource.toJson();
    var _yestodayList = getYestodayList();
    for (var i = 0; i < _yestodayList.length; i++) {
      var field = _yestodayList[i];
      var raw = data[field.key];
      var value = field.formatter != null ? field.formatter(raw) : raw;
      list.add(FractionallySizedBox(
        widthFactor: .5,
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
          child: Column(
            crossAxisAlignment:
                i % 2 == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(field.label),
              SizedBox(
                height: 8,
              ),
              BoldText(
                value,
                size: 16,
              )
            ],
          ),
        ),
      ));
    }
    return Container(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey[200], width: .5))),
            child: Row(
              children: [
                IconStats,
                SizedBox(
                  width: 5,
                ),
                BoldText(
                  'yesTitle'.tr,
                  color: Color(0xff5CC1CB),
                ),
              ],
            ),
            height: 40,
          ),
          SizedBox(
            height: 15,
          ),
          Wrap(
            children: list,
          )
        ],
      ),
    );
  }
}
