import 'package:fil/index.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:device_info/device_info.dart';
import 'package:connectivity/connectivity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

const psalt = "vFIzIawYOU";
var _box = Hive.box<Wallet>(addressBox);
Future<bool> checkNetStatus() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  bool isOn = connectivityResult != ConnectivityResult.none;
  return isOn;
}

String aesDecrypt(String raw, String mix) {
  if (raw == '') {
    return '';
  }
  var m = sha256.convert(base64.decode(mix));
  var key = encrypt.Key.fromBase64(base64.encode(m.bytes));
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cfb64));
  final encrypted = encrypt.Encrypted(base64.decode(raw));
  var decoded = encrypter.decrypt(encrypted, iv: encrypt.IV.fromLength(16));
  return decoded;
}

String encryptPrivateKey(String pk) {
  return pk;
}

String decryptPrivateKey(String pk) {
  return pk;
}

String aesEncrypt(String raw, String mix) {
  if (raw == '') {
    return '';
  }
  var m = sha256.convert(base64.decode(mix));
  var key = encrypt.Key.fromBase64(base64.encode(m.bytes));
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cfb64));
  var encoded = encrypter.encrypt(raw, iv: encrypt.IV.fromLength(16));
  return encoded.base64;
}

String tokenify(String str, {String salt = psalt}) {
  var key = utf8.encode(salt);
  var bytes = utf8.encode(str.trim());

  var hmacSha = new Hmac(sha1, key); // HMAC-SHA1
  var digest = hmacSha.convert(bytes);
  return digest.toString();
}

void unFocusOf(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void toastError(BuildContext context, {String msg = "", num sec = 2}) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text("$msg"),
    duration: Duration(seconds: sec),
    backgroundColor: Colors.red[300],
  ));
}

void copyText(String text, {Function callback}) {
  var data = ClipboardData(text: text);
  Clipboard.setData(data).then((_) {
    if (callback != null) {
      callback();
    }
  });
}

int calPasswordLevel(password) {
  var p = password.trim();
  var len = p.length;
  if (len == 0) {
    return 0;
  }
  final allDigital = RegExp(r"^\d+$");
  final allLowerAlpha = RegExp(r"^[a-z]+$");
  final allUpperAlpha = RegExp(r"^[A-Z]+$");
  final allLowerAlphaOrDigital = RegExp(r"^[a-z0-9]+$");
  final allUpperAlphaOrDigital = RegExp(r"^[A-Z0-9]+$");
  if (len < 8 ||
      allDigital.hasMatch(p) ||
      allLowerAlpha.hasMatch(p) ||
      allUpperAlpha.hasMatch(p)) {
    return 1;
  }

  if (len < 12) {
    if (allUpperAlphaOrDigital.hasMatch(p) ||
        allLowerAlphaOrDigital.hasMatch(p)) {
      return 2;
    } else {
      return 3;
    }
  }

  if (allUpperAlphaOrDigital.hasMatch(p) ||
      allLowerAlphaOrDigital.hasMatch(p)) {
    return 3;
  }

  return 4;
}

String dotString({String str = '', int headLen = 6, int tailLen = 6}) {
  int strLen = str.length;
  if (strLen < headLen + tailLen) {
    return str;
  }
  String headStr = str.substring(0, headLen);
  int tailStart = strLen - tailLen;
  String tailStr = "";
  if (tailStart > 0) {
    tailStr = str.substring(tailStart, strLen);
  }

  return "$headStr...$tailStr";
}

bool needAuth() {
  var curTime = DateTime.now();
  if (Global.latestAuthTime == null) {
    return true;
  }

  var d = curTime.difference(Global.latestAuthTime);
  if (d.inSeconds > 60) {
    Global.latestAuthTime = null;
    return true;
  }
  return false;
}

String parseE(String str) {
  final isE = RegExp(r"[eE][+-]\d+$");
  if (!isE.hasMatch(str)) {
    return str;
  }
  str = str.toLowerCase();
  var parts = str.split('e');
  var n = parts[0];
  var p = parts[1];
  var sign = p[0];
  var len = int.parse(p.substring(1)); //Number(p.slice(1))
  var r = "";
  if (sign == '+') {
    r = "1";
    for (var i = 0; i < len; i++) {
      r += "0";
    }
    n = n.replaceAll('.', '');
    r = n + r.substring(n.length);
  } else {
    r = "0.";
    for (var i = 0; i < len; i++) {
      r += "0";
    }
    n = n.replaceFirst('0', '');
    n = n.replaceFirst('.', '');
    r = r.substring(0, r.length - 1) + n;
  }
  return r;
}

String toFixed(double input, int len) {
  var r = input.toStringAsFixed(len).replaceFirst(RegExp(r"0+$"), "");
  r = r.replaceFirst(RegExp(r"\.$"), "");
  return parseE(r);
}

bool isDecimal(String input) {
  var r = RegExp(r"(^\d+(?:\.\d+)?([eE]-?\d+)?$|^\.\d+([eE]-?\d+)?$)");
  if (r.hasMatch(input.trim())) {
    return true;
  }
  return false;
}

bool isValidAddress(String input) {
  if (input.indexOf(' ') != -1) {
    return false;
  }
  var addr = input.trim().toLowerCase();
  if (addr == '') {
    return false;
  }
  var mainNet = addr[0];
  if (mainNet != 't' && mainNet != 'f') {
    return false;
  }
  var protocol = addr[1];
  if (!RegExp(r"^0|1|3$").hasMatch(protocol)) {
    return false;
  }
  var raw = addr.substring(2);
  if (protocol == "0") {
    if (raw.length > 20) {
      return false;
    }
  }
  if (protocol == "3") {
    if (raw.length < 30 || raw.length > 120) {
      return false;
    }
  }
  return true;
}

List<String> parseFee(double fee) {
  if (fee == 0) {
    return ['0', '1000'];
  } else if (fee < 0.0000001) {
    return ['1000', (fee * pow(10, 15)).toStringAsFixed(0)];
  } else {
    return [(fee * pow(10, 10)).toStringAsFixed(0), '99999999'];
  }
}

String genCKBase64(String mne) {
  var seed = bip39.mnemonicToSeed(mne);
  bip32.BIP32 nodeFromSeed = bip32.BIP32.fromSeed(seed);
  var rs = nodeFromSeed.derivePath("m/44'/461'/0'/0");
  var rs0 = rs.derive(0);
  var ck = base64Encode(rs0.privateKey);
  return ck;
  // var mergeMethods = [
  //   (a, b) => ((a << 4) & 0xFF) | (b >> 4),
  //   (a, b) => a & b,
  //   (a, b) => ((b << 4) & 0xFF) | (a >> 4),
  //   (a, b) => a ^ b,
  // ];
  // var seed = bip39.mnemonicToSeed(mne);
  // //print(seed);
  // var l = seed.length;
  // var n = l / 2;
  // Uint8List b32 = Uint8List(32);
  // for (var i = 0; i < n; i++) {
  //   var mm = mergeMethods[i % mergeMethods.length];
  //   b32[i] = mm(seed[i], seed[l - 1 - i]);
  // }
  // //print(b32);
  // var ck = base64Encode(b32);
  // //print(ck);
  // return ck;
}

Future<AndroidDeviceInfo> getAndroidDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
  print("android device id is:");
  print(androidInfo.androidId);

  return androidInfo;
}

String genRandStr(int size) {
  String str = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  String result = "";
  var strLen = str.length;
  for (int i = 0; i < size; i++) {
    result += str[Random().nextInt(strLen)];
  }
  return result;
}

String hex2str(String hexString) {
  hexString = hexString.trim();
  List<String> split = [];
  for (int i = 0; i < hexString.length; i = i + 2) {
    split.add(hexString.substring(i, i + 2));
  }
  String ascii = List.generate(split.length,
      (i) => String.fromCharCode(int.parse(split[i], radix: 16))).join();
  return ascii;
}

String formatTime(num timestamp) {
  if (timestamp == null) {
    return '';
  }
  var t = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return "${t.year.toString().substring(2)}/${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
}

String fixedFloat({String number, num size = 2}) {
  var arr = number.split('.');
  var intStr = arr[0];
  var dotStr = arr[1];
  if (dotStr != null) {
    return (double.parse(intStr) + double.parse('0.$dotStr').toPrecision(size))
        .toString();
  } else {
    return number;
  }
}

String truncate(double value, {int size = 4}) {
  return ((value * pow(10, size)).floor() / pow(10, size)).toString();
}


String formatFil(String attoFil, {num size = 4,bool fixed=false}) {
  if(attoFil=='0'){
    return '0 FIL';
  }
  try {
    var str = attoFil;
    var v = BigInt.parse(attoFil);
    num length = str.length;
    if (length < 5) {
      return '$str attoFIL';
    } else if (length >= 5 && length <= 13) {
      var unit = BigInt.from(pow(10, 9));
      var res = v / unit;
      return fixed?'${res.toStringAsFixed(size)} nanoFIL':'${truncate(res)} nanoFIL';
    } else {
      var unit = BigInt.from(pow(10, 18));
      var res = v / unit;
      return fixed?'${res.toStringAsFixed(size)} FIL':'${truncate(res, size: size)} FIL';
    }
  } catch (e) {
    return attoFil;
  }
}

String fil2Atto(String fil) {
  if (fil == null || fil == '') {
    fil = '0';
  }
  return (BigInt.from((double.parse(fil) * pow(10, 9))) *
          BigInt.from(pow(10, 9)))
      .toString();
}

String atto2Fil(String value, {num len = 6}) {
  try {
    if (value == null || value == '') {
      value = '0';
    }
    return Fil(attofil: value).toFixed(len: len);
  } catch (e) {
    return '';
  }
}

String unitConversion(String byteStr, num length) {
  try {
    int byte = int.parse(byteStr);
    String res = '';
    var positive = true;
    if (byte == 0) {
      return "0 bytes";
    }
    if (byte < 0) {
      positive = false;
      byte = byte.abs();
      res = byte.abs().toString();
    }
    var k = 1024;
    var sizes = [
      "bytes",
      "KiB",
      "MiB",
      "GiB",
      "TiB",
      "PiB",
      "EiB",
      "ZiB",
      "YiB"
    ];
    var c = (log(byte) / log(k)).truncate();
    if (c < 0) {
      res = '';
    } else {
      res = (byte / pow(k, c)).toStringAsFixed(length) + " " + sizes[c];
    }

    return positive ? res : '-$res';
  } catch (e) {
    return '';
  }
}

String unitTime(num time) {
  var minuteUnit = 60;
  var hourUnit = minuteUnit * 60;
  var dayUnit = hourUnit * 24;
  List<int> numArr = [];
  var unitArr = [dayUnit, hourUnit, minuteUnit];
  var suffix =
      Global.t.langCode == 'en' ? ['day', 'hr', 'min'] : ['天', '时', '分'];
  unitArr.forEach((unit) {
    var n = time ~/ unit;
    time = time - n * unit;
    numArr.add(n);
  });

  var strArr = numArr
      .asMap()
      .entries
      .map((e) {
        var i = e.key;
        return '${numArr[i]}${suffix[i]}';
      })
      .where((element) => element[0] != '0')
      .toList()
      .join(' ');
  return strArr;
}

String walletLabel(String addr, {bool dot = true}) {
  return _box.containsKey(addr)
      ? _box.get(addr).label
      : dot
          ? dotString(str: addr)
          : addr;
}

bool isExistWallet(String addr) {
  return _box.containsKey(addr);
}

String encodeString(String str, [int times = 1]) {
  List<int> s = utf8.encode(str);
  return base64Encode(s);
}

String decodeString(String str) {
  return utf8.decode(base64Decode(str));
}

int getSecondSinceEpoch() {
  return (DateTime.now().millisecondsSinceEpoch / 1000).truncate();
}

String formatDouble(String str, {bool truncate = false, int size = 4}) {
  try {
    var v = double.parse(str);
    if (v == 0.0) {
      return '0';
    } else {
      if (truncate) {
        return ((v * pow(10, size)).floor() / pow(10, size)).toString();
      } else {
        return str;
      }
    }
  } catch (e) {
    return '0';
  }
}

String getFilBalance(String str) {
  return formatDouble(str, truncate: true, size: 2) + ' FIL';
}

bool isValidPassword(String pass) {
  pass = pass.trim();
  var reg = RegExp(r'^(?=.*[0-9].*)(?=.*[A-Z].*)(?=.*[a-z].*).{8,20}$');
  return reg.hasMatch(pass);
}

String base64ToHex(String pk, String type) {
  String t = type == '1' ? 'secp256k1' : 'bls';
  PrivateKey privateKey = PrivateKey(t, pk);
  String result = '';
  var list = BinaryWriter.utf8Encoder.convert(jsonEncode(privateKey.toJson()));
  for (var i = 0; i < list.length; i++) {
    result += list[i].toRadixString(16);
  }
  return result;
}

String getMaxFee(Gas gas) {
  var feeCap = gas.feeCap;
  var gasLimit = gas.gasLimit;

  return formatFil(BigInt.from((double.parse(feeCap) * gasLimit)).toString(),fixed: true);
}

Future openInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
    );
  } else {
    throw 'Could not launch $url';
  }
}

String balanceFormatter(dynamic value) {
  value = value as String;
  if (value == '0') {
    return '0';
  }
  return double.parse(value).toStringAsFixed(2) + ' FIL';
}

void nextTick(Noop callback) {
  Future.delayed(Duration.zero).then((value) {
    callback();
  });
}
