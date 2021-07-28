import 'package:fil/index.dart';

Future registerJpushId(String id) async {
  var data = <String, String>{
    'uuid': Global.uuid,
    'platform': Global.platform,
    'registerId': id
  };
  var response =
      await Dio().post('${apiMap[mode]}/jpush/registerId', data: data);
  if (response.data['code'] == 0) {
    Global.store.setBool('jpush_registered', true);
  } else {
    Global.store.setBool('jpush_registered', false);
  }
}

void switchWalletPushStatus(String addr, bool status) async{
  var box =OpenedBox.addressInsance;
  var wallet = box.get(addr);
  wallet.push = status;
  await box.put(addr, wallet);
}

Future<bool> registerJpushAddress(String address) async {
  try {
    var data = <String, String>{
      'uuid': Global.uuid,
      'registerId': Global.registerId,
      'address': address
    };
    var response =
        await Dio().post('${apiMap[mode]}/jpush/registerAddress', data: data);
    if (response.data['code'] == 0) {
      switchWalletPushStatus(address, true);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> deleteJpushAddress(address) async {
  var data = <String, String>{'uuid': Global.uuid, 'address': address};
  try {
    var response =
        await Dio().post('${apiMap[mode]}/jpush/deleteAddress', data: data);
        print(response);
    if (response.data['code'] == 0) {
      switchWalletPushStatus(address, false);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e);
    return false;
  }
}
