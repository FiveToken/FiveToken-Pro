import 'package:fil/index.dart';
import 'package:flutter/services.dart' show rootBundle;

class Translation {
  Map<String, Map<String, dynamic>> _cache = {};
  Map<String, dynamic> _local = {};
  String langCode;

  Future loadText(String lang) async {
    langCode = lang;
    if (_cache[lang] != null) {
      _local = _cache[lang];
    } else {
      String res = await rootBundle.loadString('locale/$lang.json');
      _local = jsonDecode(res);
      _cache[lang] = _local;
    }
  }

  Map<String, dynamic> getByKey(String key) {
    List<String> karr = key.split('.');

    Map<String, dynamic> res = _local;
    for (var i = 0; i < karr.length; i++) {
      res = res[karr[i]];
      if (res == null) {
        return null;
      }
    }

    return res;
  }

  String getValue(String key,{Map<String,dynamic> data}) {
    num idx = key.lastIndexOf('.');
    if (idx == -1) {
      return key;
    }
    String pre = key.substring(0, idx);
    String k = key.substring(idx + 1);
    Map<String, dynamic> f = this.getByKey(pre);
    if (f == null) {
      return key;
    }
    if (f[k] == null) {
      return key;
    }
    if(data!=null){
      var str=f[k] as String;
      data.forEach((key, value) { 
        str=str.replaceAll('{$key}', value);
      });
      return str;
    }
    return f[k];
  }
}

String tr(String key,{Map<String,dynamic> data}) {
  return Global.t.getValue(key,data: data);
}

class LocaleChangeEvent {}
