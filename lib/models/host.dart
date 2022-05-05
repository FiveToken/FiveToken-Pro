/// key : ""
/// value : ""

class Host {
  Host({
    this.key,
    this.value,
  });

  Host.fromJson(dynamic json) {
    key = json['key'] as String;
    value = json['value'] as String;
  }
  String key;
  String value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['key'] = key;
    map['value'] = value;
    return map;
  }
}
