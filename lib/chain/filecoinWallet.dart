import 'package:bls/bls.dart';
import 'package:fil/common/libsodium.dart';
import 'package:fil/common/utils.dart';
import 'package:flotus/flotus.dart';
import 'package:fil/utils/enum.dart';

class FilecoinWallet {
  static String genPrivateKeyByMne(String mne) {
    var ck = genCKBase64(mne);
    return ck;
  }

  static Future<String> genAddressByPrivateKey(String ck,
      {String type = 'secp', String prefix = 'f'}) async {
    String pk = '';
    if (type == SignStringType.secp) {
      pk = await Flotus.secpPrivateToPublic(ck: ck);
    } else {
      type = SignStringType.bls;
      pk = await Bls.pkgen(num: ck);
    }
    String address = await Flotus.genAddress(pk: pk, t: type);
    return prefix + address.substring(1);
  }

  static Future<String> genAddressByMne(String mne) async {
    try {
      var privateKey = FilecoinWallet.genPrivateKeyByMne(mne);
      var address = await FilecoinWallet.genAddressByPrivateKey(privateKey);
      return address;
    } catch (e) {
      return '';
    }
  }

  static Future<bool> validatePrivateKey(
      String privateKey, String address, String password) async {
    try {
      String decrypted = await decryptSodium(privateKey, address, password);
      if (decrypted != '') {
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
