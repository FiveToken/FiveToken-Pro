import 'package:hive/hive.dart';
part 'monitor.g.dart';

@HiveType(typeId: 6)
class MonitorAddress {
  @HiveField(0)
  String label;
  @HiveField(1)
  String cid;
  @HiveField(2)
  String threshold;
  @HiveField(3)
  String type;
  @HiveField(4)
  String miner;
  MonitorAddress({this.label, this.cid, this.threshold, this.type,this.miner});
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'cid': cid,
      'threshold': threshold,
      'type': type,
      'miner': miner
    };
  }
}
