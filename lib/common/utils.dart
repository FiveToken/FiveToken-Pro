import 'package:decimal/decimal.dart';
import 'package:fil/index.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

const psalt = "vFIzIawYOU";

/// decrypt the string that was encrypted
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

/// use aes algorithm to encrypt a string
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

/// generate the digest of the given string
String tokenify(String str, {String salt = psalt}) {
  var key = utf8.encode(salt);
  var bytes = utf8.encode(str.trim());

  var hmacSha = new Hmac(sha1, key); // HMAC-SHA1
  var digest = hmacSha.convert(bytes);
  return digest.toString();
}

/// hide keyboard
void unFocusOf(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

/// set  data of clipboard to the given [text] then call the [callback]
void copyText(String text, {Function callback}) {
  var data = ClipboardData(text: text);
  Clipboard.setData(data).then((_) {
    if (callback != null) {
      callback();
    }
  });
}

/// convert a long string to short
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

/// verify if [input] is a valid double number
bool isDecimal(String input) {
  var r = RegExp(r"(^\d+(?:\.\d+)?([eE]-?\d+)?$|^\.\d+([eE]-?\d+)?$)");
  if (r.hasMatch(input.trim())) {
    return true;
  }
  return false;
}

/// verify if [input] is a valid filecoin address
bool isValidAddress(String input) {
  if (input.indexOf(' ') != -1) {
    return false;
  }
  var addr = input.trim().toLowerCase();
  if (addr == '') {
    return false;
  }
  var net = addr[0];
  if (net != Global.netPrefix) {
    return false;
  }
  var protocol = addr[1];
  if (!RegExp(r"^0|1|2|3$").hasMatch(protocol)) {
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

/// generate private key by [mne]
String genCKBase64(String mne) {
  var seed = bip39.mnemonicToSeed(mne);
  bip32.BIP32 nodeFromSeed = bip32.BIP32.fromSeed(seed);
  var rs = nodeFromSeed.derivePath("m/44'/461'/0'/0");
  var rs0 = rs.derive(0);
  var ck = base64Encode(rs0.privateKey);
  return ck;
}

/// convert hex encode string
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

/// convert attoFil to different units
String formatFil(String attoFil,
    {num size = 4, bool fixed = false, bool returnRaw = false}) {
  if (attoFil == '0') {
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
      return fixed
          ? '${res.toStringAsFixed(size)} nanoFIL'
          : '${truncate(res)} nanoFIL';
    } else {
      var unit = BigInt.from(pow(10, 18));
      var res = v / unit;
      if (returnRaw) {
        return double.parse(res.toStringAsFixed(8)).toString() + ' FIL';
      }
      return fixed
          ? '${res.toStringAsFixed(size)} FIL'
          : '${truncate(res, size: size)} FIL';
    }
  } catch (e) {
    return attoFil;
  }
}

/// convert fil to attofil
String fil2Atto(String fil) {
  if (fil == null || fil == '') {
    fil = '0';
  }
  return (Decimal.parse(fil) * Decimal.fromInt(pow(10, 18))).toString();
}

/// convert bytes to different units
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

/// verify if the [pass] is valid
bool isValidPassword(String pass) {
  pass = pass.trim();
  var reg = RegExp(r'^(?=.*[0-9].*)(?=.*[A-Z].*)(?=.*[a-z].*).{8,20}$');
  return reg.hasMatch(pass);
}

/// convert a base64 encode private key to hex encode private key. [type] represent different algorithm
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

/// launch a [url] to open other app or open in browser
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

/// call a function in next tick
void nextTick(Noop callback) {
  Future.delayed(Duration.zero).then((value) {
    callback();
  });
}

String getMaxFee(Gas gas) {
  var feeCap = gas.feeCap;
  var gasLimit = gas.gasLimit;

  return formatFil(BigInt.from((double.parse(feeCap) * gasLimit)).toString(),
      fixed: true);
}

String truncate(double value, {int size = 4}) {
  var unit = Decimal.fromInt(pow(10, size));
  var d = Decimal.parse(value.toString()) * unit;
  return (d.truncate() / unit).toString();
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
