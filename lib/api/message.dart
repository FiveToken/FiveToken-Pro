import 'dart:io';
import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';

var messageApi = 'https://api.filwallet.ai:5679/rpc/v0';
// var messageApi = 'http://192.168.1.189:5678/rpc/v0';
var mesMap = {
  't': 'http://192.168.1.189:5678/rpc/v0',
  'f': 'https://api.filwallet.ai:5679/rpc/v0'
};
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
      showCustomError(res.error['message']);
      Map<String, dynamic> params = {};
      var m = msg['Message'];
      params['from'] = m['From'];
      params['to'] = m['To'];
      params['value'] = m['Value'];
      params['method'] = m['Method'];
      params['err_msg'] = res.error['message'];
      addError(params);
      showCustomError(getErrorMessage(res.error['message']));
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
    return 'pushFail'.tr;
  }
}

void addError(Map<String, dynamic> data) async {
  var response = await Dio().post('${apiMap[mode]}/error/addMsg', data: data);
  if (response.data['code'] == 0) {
    print('add error success');
  } else {
    print('add error fail');
  }
}

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

void addRequestTime(String method, int time, String params) async {
  Map<String, dynamic> data = {
    "method": method,
    "time": time,
    "platform": Platform.operatingSystem,
    "params": params
  };
  var response = await Dio().post('${apiMap[mode]}/request/add', data: data);
  if (response.data['code'] == 0) {
    print('add time success');
  } else {
    print('add time fail');
  }
}

Future<List> getMessageList(
    {String address = '',
    num time,
    String direction = 'up',
    num count = 80}) async {
  time ??= (DateTime.now().millisecondsSinceEpoch / 1000).truncate() - 3600;
  try {
    var result = await fetch("filscan.MessageByAddressDirection", [
      {
        "address": Global.netPrefix + address.substring(1),
        "timePoint": time,
        "direction": direction,
        "count": count,
        "method": ""
      }
    ]);
    //var result = await Global.dio.post('/rpc/v1', data: data);
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

Future<MessageDetail> getMessageDetail(StoreMessage mes) async {
  var result = await fetch('filscan.MessageDetails', [mes.signedCid]);
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    return MessageDetail.fromJson(mes.toJson());
  }
  var res = response.result;
  if (res != null) {
    var message = MessageDetail.fromJson(res);
    message.blockCid = res['blk_cids'] != null ? res['blk_cids'][0] : '';
    return message;
  } else {
    return MessageDetail.fromJson(mes.toJson());
  }
}

Future<Gas> getGasInfo(Map<String, dynamic> map) async {
  var data =
      JsonRPCRequest(1, "Filecoin.GasEstimateMessageGas", [map, null, []]);
  var result = await Global.dio
      .post(
    "/rpc/v1",
    data: data,
  )
      .catchError((e) {
    print(e);
  });
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    return Gas();
  }
  var res = response.result;
  if (res != null) {
    var feeCap = res["GasFeeCap"];
    var gasLimit = res["GasLimit"];
    var premium = res["GasPremium"];
    return Gas(feeCap: feeCap, gasLimit: gasLimit, premium: premium);
  } else {
    return Gas();
  }
}

Future<TMessage> buildMessage(Map<String, dynamic> map, String params) async {
  var result =
      await fetch("filscan.BuildMessage", [map, params, 0], loading: true);
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    showCustomError(response.error['message']);
    return TMessage();
  } else {
    var res = response.result;
    if (res != null) {
      return TMessage.fromJson(res);
    } else {
      return TMessage();
    }
  }
}

Future<Gas> getGasDetail({num method = 0, String to}) async {
  if (to == null || to == '') {
    to = Global.netPrefix + '099';
  }
  var empty = Gas();
  var result = await fetch("filscan.BaseFeeAndGas", [to, method]);
  print(result);
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

Future<List> getMultiMessageList(
    {String address = '',
    num time,
    String direction = 'up',
    String method = 'Propose',
    num count = 80}) async {
  time ??= (DateTime.now().millisecondsSinceEpoch / 1000).truncate();
  var result = await fetch("filscan.MsigMessageByAddressDirection", [
    {
      "address": Global.netPrefix + address.substring(1),
      "timePoint": time,
      "direction": direction,
      "count": count,
      "method": method
    }
  ]);
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

Future<MultiWalletInfo> getMultiInfo(String id) async {
  try {
    var result = await fetch("filscan.MsigAddressState", [id]);
    var response = JsonRPCResponse.fromJson(result.data);
    if (response.error != null) {
      return MultiWalletInfo();
    }
    var res = response.result;
    if (res != null && res['signers'] != null) {
      if (res['signers'] is List) {
        var info = MultiWalletInfo(
            signerMap: {},
            balance: res['balance'],
            robustAddress: res['robust_address'],
            approveRequired: res['approve_required']);
        (res['signers'] as List).forEach((element) {
          var m = element as Map<String, dynamic>;
          m.entries.forEach((e) {
            info.signerMap[e.value] = e.key;
          });
        });
        return info;
      } else {
        return MultiWalletInfo();
      }
    } else {
      return MultiWalletInfo();
    }
  } catch (e) {
    dismissAllToast();
    return MultiWalletInfo();
  }
}