import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  final raw = FilPrivate;
  group("test aes", () {
    var encryptStr =
        'hp2iyoU5O4kODbx3QBo4RT2Y++7Ix5MIZeHrdQbhLJ1p9vOIv4CZB2rJsWUHNJqN';
    test("aes encrypt", () {
      var res = aesEncrypt(raw, raw);
      expect(res, encryptStr);
    });
    test("aes decrypt", () {
      var res = aesDecrypt(encryptStr, raw);
      expect(res, raw);
    });
  });
  test("generate hash", () {
    var res = tokenify(raw);
    var hash = 'a4e24708494a335e1c76d237059f069b58e8e715';
    expect(res, hash);
  });
  test('dot string', () {
    var addr =
        'f3ru7s7lajvcdcagztyz6qfo5qnlu6h6xzazg4eqwfyyexff36tkeg2ce2raidffniq222qpr2rvtfjwvwikaa';
    var dotStr = 'f3ru7s...vwikaa';
    var res = dotString(str: addr);
    expect(res, dotStr);
  });
  test('check  input is a valid decimal ', () {
    var numStr = '1.23';
    var wrongStr = '1..23';
    var wrongStr2 = '1..23e';
    expect(isDecimal(numStr), true);
    expect(isDecimal(wrongStr), false);
    expect(isDecimal(wrongStr2), false);
  });
  test('generate private key by mne', () {
    var pk = genCKBase64(Mne);
    expect(pk, raw);
  });
  test('test input address is valid', () {
    var addr1 = FilAddr;
    var addr2 = 'f25jeueztvocvwkl65xzyabcpxhcaavxc5gmnxrhi';
    var addr3 =
        'f3rjbjckhn3ll2wwptwxvnq32gydmofom2cwdxllxnazhgs3igmbdbnoh45ec2pxwrsvpjq5njezt5mchpxxxq';
    expect(isValidAddress(addr1), true);
    expect(isValidAddress(addr2), true);
    expect(isValidAddress(addr3), true);
  });
  test('test convert hex to string', () {
    var hex = '66697665746f6b656e';
    expect(hex2str(hex), WalletLabel);
  });
  test('test format atto fil', () {
    var value1 = '1';
    var value2 = '120000000000';
    var value3 = '123000000000000000000';
    expect(formatFil(value1), '1 attoFIL');
    expect(formatFil(value2), '120 nanoFIL');
    expect(formatFil(value3), '123 FIL');
  });
  test('test convert fil to atto', () {
    var value = '1.23';
    expect(fil2Atto(value), '1230000000000000000');
  });
  test('test convert bytes', () {
    var bytes1 = '1';
    var bytes2 = '1234';
    var bytes3 = '123456789';
    expect(unitConversion(bytes1, 1), '1.0 bytes');
    expect(unitConversion(bytes2, 2), '1.21 KiB');
    expect(unitConversion(bytes3, 3), '117.738 MiB');
  });
  test('check password', () {
    var pass = 'Aa123456';
    var wrongPass = 'Aa12345';
    var wrongPass2 = 'a1234567';
    var wrongPass3 = '12345678';
    var wrongPass4 = 'Aabcdefg';
    expect(isValidPassword(pass), true);
    expect(isValidPassword(wrongPass), false);
    expect(isValidPassword(wrongPass2), false);
    expect(isValidPassword(wrongPass3), false);
    expect(isValidPassword(wrongPass4), false);
  });
  test('convert base64 to hex', () {
    var res = base64ToHex(raw, '1');
    var hex =
        '7b2254797065223a22736563703235366b31222c22507269766174654b6579223a22413066553636356f5a67514d46656b5144434c31686872456b76464e445955766a39336d4c5565703079493d227d';
    expect(res, hex);
  });
  test('test get max fee', () {
    var gas = Gas(gasLimit: 1000000, feeCap: '1230000000');
    expect(getMaxFee(gas), '0.0012 FIL');
  });
  test('test truncate', () {
    var value = 1.23456;
    expect(truncate(value), '1.2345');
  });
  test('format double', () {
    var value = '1.23456';
    expect(formatDouble(value), '1.23456');
    expect(formatDouble(value,truncate: true), '1.2345');
  });
}
