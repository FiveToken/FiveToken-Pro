import 'dart:io';
import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';

var mesMap = {
  't': 'http://192.168.1.189:5678/rpc/v0',
  'f': 'https://api.filwallet.ai:5679/rpc/v0'
};

/// push signed message to lotus
Future<String> pushSignedMsg(Map<String, dynamic> msg) async {
  var data = JsonRPCRequest(1, "Filecoin.MessagePush", [msg]);
  try {
    showCustomLoading('sending'.tr);
    var rs = await Dio().post(
      mesMap[Global.netPrefix],
      data: data,
    );
    dismissAllToast();
    print(rs);
    var res = JsonRPCResponse.fromJson(rs.data);
    if (res.error != null) {
      Map<String, dynamic> params = {};
      var m = msg['Message'];
      params['from'] = m['From'];
      params['to'] = m['To'];
      params['value'] = m['Value'];
      params['method'] = m['Method'];
      params['err_msg'] = res.error['message'];
      addError(params);
      var mes=getErrorMessage(res.error['message']);
      showCustomError(mes);
      return '';
    } else if (res.result != null && res.result['/'] != null) {
      showCustomToast('sended'.tr);
      return res.result['/'];
    } else {
      return '';
    }
  } catch (e) {
    print(e);
    dismissAllToast();
    return '';
  }
}

/// format error message when push message failed
String getErrorMessage(String message) {
  if (message.contains('nonce')) {
    return 'wrongNonce'.tr;
  } else if (message.contains('cap')) {
    return 'lowFeeCap'.tr;
  } else if (message.contains('less than')) {
    return 'capLessThanPremium'.tr;
  } else if (message.contains('signature')) {
    return 'wrongSignature'.tr;
  } else if (message.contains('funds')) {
    return 'errorLowBalance'.tr;
  } else {
    return 'sendFail'.tr;
  }
}

/// collect error
void addError(Map<String, dynamic> data) async {
  var response = await Dio().post('${apiMap[mode]}/error/addMsg', data: data);
  if (response.data['code'] == 0) {
    print('add error success');
  } else {
    print('add error fail');
  }
}

///collect app run error
void addAppError(String err) async {
  Map<String, String> data = {
    "platform": Platform.operatingSystem,
    "uuid": Global.uuid ?? "",
    "os_version": Global.os,
    "app_version": Global.version,
    "err_msg": err
  };
  var response = await Dio().post('${apiMap[mode]}/error/addApp', data: data);
  if (response.data['code'] == 0) {
    print('add error success');
  } else {
    print('add error fail');
  }
}

/// record request time
void addRequestTime(String method, int time, String params) async {
  Map<String, dynamic> data = {
    "method": method,
    "time": time,
    "platform": Platform.operatingSystem,
    "params": params
  };
  var response = await Dio().post('${apiMap[mode]}/request/add', data: data);
  if (response.data['code'] == 0) {
    print('add time success method:$method');
  } else {
    print('add time fail');
  }
}

/// get messages related to the specified address
///  [address]  address use to search
///  [timePoint]  tipset timestamp
///  [direction]  'up': find messages before [timePoint] 'down': find messages after [timePoint]
///  [count] num of the messages
///  [method] message's method
Future<List> getMessageList(
    {String address = '',
    num time,
    num count = 20}) async {
  time ??= (DateTime.now().millisecondsSinceEpoch / 1000).truncate() - 3600;
  try {
    var result = await fetch("filscan.MessageByAddressDirection", [
      {
        "address": Global.netPrefix + address.substring(1),
        "timePoint": time,
        "direction": 'up',
        "count": count,
        "method": ""
      }
    ]);
    if (result.data == null) {
      return [];
    }
    var response = JsonRPCResponse.fromJson(result.data);
    if (response.error != null) {
      return [];
    }
    var res = response.result;
    if (res != null) {
      if (res["data"] != null && res['data'] is List) {
        return res['data'];
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

/// get the message detail infomation by signed cid
Future<MessageDetail> getMessageDetail(StoreMessage mes) async {
  var result = await fetch('filscan.MessageDetails', [mes.signedCid]);
  var empty = MessageDetail.fromJson(mes.toJson());
  if (result.data == null) {
    return empty;
  }
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    return empty;
  }
  var res = response.result;
  if (res != null) {
    var message = MessageDetail.fromJson(res);
    message.blockCid = res['blk_cids'] != null ? res['blk_cids'][0] : '';
    return message;
  } else {
    return empty;
  }
}

/// pass unserialized params to get a unsigned message
///  [map] message fields: from to and value
///  [params] raw params in json string
Future<TMessage> buildMessage(Map<String, dynamic> map, String params) async {
  var result = await fetch("filscan.BuildMessage", [map, params, 0]);
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    showCustomError(response.error['message']);
    throw Exception("make message fail");
  } else {
    var res = response.result;
    if (res != null) {
      return TMessage.fromJson(res);
    } else {
      throw Exception("make message fail");
    }
  }
}

/// get gas_limit,gas_premium and base_fee to predict gas
///  [method]  'method' filed in message
///  [to] 'to' field in message
Future<Gas> getGasDetail({num method = 0, String to}) async {
  if (to == null || to == '') {
    to = FilecoinAccount.f099;
  }
  var empty = Gas();
  var result = await fetch("filscan.BaseFeeAndGas", [to, method]);
  print(result);
  if (result.data == null) {
    return empty;
  }
  var response = JsonRPCResponse.fromJson(result.data);

  if (response.error != null) {
    return empty;
  }
  var res = response.result;
  if (res != null) {
    var baseFee = res['base_fee'] ?? '0';
    //var gasUsed = res['gas_used'] ?? '0';
    var limit = res['gas_limit'] ?? '0';
    var premium = res['gas_premium'] ?? '100000';
    var exist = res['actor_exist'] ?? true;
    try {
      var baseFeeNum = int.parse(baseFee);
      //var gasUsedNum = int.parse(gasUsed);
      var limitNum = int.parse(limit);
      var premiumNum = int.parse(premium);
      var feeCap = 3 * baseFeeNum + premiumNum;
      //var gasLimit = (1.25 * gasUsedNum).truncate();
      if (method == 0 && !exist) {
        limitNum = 2200000;
      }
      return Gas(
          baseFee: baseFee,
          feeCap: feeCap.toString(),
          premium: premiumNum.toString(),
          gasLimit: limitNum);
    } catch (e) {
      return empty;
    }
  } else {
    return empty;
  }
}

/// get multi-sig messages related to the specified address
///  [address]  address use to search
///  [timePoint]  tipset timestamp
///  [direction]  'up': find messages before [timePoint] 'down': find messages after [timePoint]
///  [count] num of the messages
///  [method] 'Propose': message whose method name  is 'Propose' 'Approve': message whose method name  is 'Approve'
Future<List> getMultiMessageList(
    {String address = '',
    num time,
    String method = 'Propose',
    num count = 80}) async {
  time ??= (DateTime.now().millisecondsSinceEpoch / 1000).truncate();
  var result = await fetch("filscan.MsigMessageByAddressDirection", [
    {
      "address": Global.netPrefix + address.substring(1),
      "timePoint": time,
      "direction": 'up',
      "count": count,
      "method": method
    }
  ]);
  if (result.data == null) {
    return [];
  }
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    return [];
  }
  var res = response.result;
  if (res != null) {
    if (res["data"] != null && res['data'] is List) {
      return res['data'];
    } else {
      return [];
    }
  } else {
    return [];
  }
}


