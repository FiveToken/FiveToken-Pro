import 'dart:math';
import 'package:bls/bls.dart';
import 'package:dio/dio.dart';
import 'package:fil/api/update.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/conf/conf.dart';
import 'package:fil/data/preferences_manager.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/gas.dart';
import 'package:fil/models/message.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/models/nonce.dart';
import 'package:fil/models/noop.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/pages/transfer/transfer.dart';
import 'package:fil/repository/http/http.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/style.dart';
import 'package:flotus/flotus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';
import 'package:fil/common/private.dart';
import 'dart:convert';

import 'constant.dart';

class FilecoinResponse {
  int code;
  dynamic data;
  String message;
  String detail;

  FilecoinResponse({this.code, this.data, this.message, this.detail});

  FilecoinResponse.fromJson(Map<String, dynamic> map) {
    code = map['code'] as int;
    data = map['data'];
    message = map['message'] as String;
    detail = map['detail'] as String;
  }
}

Future fetchPing() async {
  List<String> hostList = [];
  for (var i = 1; i < 16; i++) {
    String hash = await sha256hash('fivetoken${i}');
    String hostMid =
        hash.substring(0, 4) + hash.substring(hash.length - 9, hash.length - 1);
    String host = 'https://api${hostMid}.xyz/api/7om8n3ri4v23pjjfs4ozctlb';
    hostList.add(host);
  }
  try {
    final one = await Future.any(hostList.map((e) => _callPing(e + '/ping')));
    await PreferencesManager.setString('host', one.data['data'] as String);
    return one;
  } catch (e) {
    return null;
  }
}

Future _callPing(String url) async {
  try {
    return await http.get(url);
  } catch (e) {
    await Future.delayed(Duration(seconds: 30));
  }
}

String GetBaseUrl() {
  String host = PreferencesManager.getString('host') as String;
  return host != null
      ? "https://" + host + "/api/7om8n3ri4v23pjjfs4ozctlb"
      : 'https://api.fivetoken.io/api/7om8n3ri4v23pjjfs4ozctlb';
}

class FilecoinProvider {
  Dio client;
  static String balancePath = '/actor/balance';
  static String idPath = '/actor/id';
  static String pushPath = '/message';
  static String messageListPath = '/actor/messages';
  static String feePath = '/recommend/fee';
  static String multiPath = '/actor/msig/state';
  static String buildPath = '/message/build';
  static String proposePath = '/proposes';
  static String proposeDetailPath = '/propose/detail';
  static String typePath = '/actor/type';
  static String minerMetaPath = '/miner/indicator';
  static String minerPowerPath = '/miner/power/24h';
  static String minerRelatedAddressPath = '/miner/balances';
  static String minerBalancePath = '/miner/base';
  static String multiDepositPath = '/actor/msig/deposits';
  static String minersPath = '/owner/miner/active';
  static String serializePath = '/message/msig/construct';
  static String decodeParamsPath = '/message/params/decode';
  static String pricePath = '/token/price';
  static String clientId = ClientID;
  static String baseUrl() {
    return GetBaseUrl();
  }

  FilecoinProvider({Dio httpClient}) {
    client = httpClient ?? Dio();
    if (httpClient == null) {
      // client.options.baseUrl = 'http://192.168.1.161:8081/api/test';
      client.options.baseUrl = baseUrl();
      print(client.options.baseUrl);
      client.options.connectTimeout = Timeout.medium;
      client.interceptors
          .add(InterceptorsWrapper(onRequest: (options, handler) {
        options.headers.addAll({
          'X-Client-Info': jsonEncode({
            'platform': Global.platform,
            'version': Global.version,
            'uuid': Global.uuid
          })
        });
        return handler.next(options);
      }));
    }
  }

  Future<String> getActorId(String addr) async {
    try {
      var result = await client.get(idPath, queryParameters: {"address": addr});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        return response.data as String;
      } else {
        throw Exception('get actor id fail');
      }
    } catch (e) {
      throw Exception('get actor id fail');
    }
  }

  Future sendSignedMessage(
    Map<String, dynamic> message, {
    ValueChanged<String> callback,
  }) async {
    showCustomLoading('sending'.tr);
    var result = await client
        .post(pushPath, data: {'cid': '', 'raw': jsonEncode(message)});
    dismissAllToast();
    var response =
        FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
    if (response.code == 200 && response.data != null) {
      showCustomToast('tradeSucc'.tr);
      var res = response.data;
      if (callback != null) {
        callback(res as String);
      }
    } else {
      throw (response.detail);
    }
  }

  Future<void> sendMessage({
    @required TMessage message,
    @required String private,
    String multiId = '',
    String methodName = 'transfer',
    String multiTo,
    ValueChanged<String> callback,
    bool increaseNonce = false,
    CacheMultiMessage multiMessage,
  }) async {
    try {
      String sign = '';
      num signType;
      if (increaseNonce) {
        var nonce = message.nonce;
        OpenedBox.pushInsance.values
            .where((mes) => mes.from == $store.wal.addressWithNet)
            .forEach((mes) {
          if (mes.nonce != null && mes.nonce > nonce) {
            nonce = mes.nonce;
          }
        });
        message.nonce = nonce + 1;
      }
      var cid =
          await Flotus.messageCid(msg: jsonEncode(message.toLotusMessage()));
      if (message.from[1] == '1') {
        signType = SignTypeSecp;
        sign = await Flotus.secpSign(ck: private, msg: cid);
      } else {
        signType = SignTypeBls;
        sign = await Bls.cksign(num: "$private $cid");
      }
      var from = message.from;
      var to = message.to;
      var nonce = message.nonce;
      var value = message.value;
      var sm = SignedMessage(message, Signature(signType, sign));
      print(jsonEncode(sm.toLotusSignedMessage()));
      showCustomLoading('sending'.tr);
      var result = await client.post(pushPath,
          data: {'cid': cid, 'raw': jsonEncode(sm.toLotusSignedMessage())});
      dismissAllToast();
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        if (response.data is String && response.data != '') {
          showCustomToast('tradeSucc'.tr);
          String res = response.data as String;
          $store.setGas(Gas());
          $store.setNonce(-1);
          var now = getSecondSinceEpoch();
          var m = message.method;
          var isCreate = message.to == FilecoinAccount.f01;
          StoreMessage msgData = StoreMessage(
              pending: 1,
              from: from,
              to: to,
              value: value,
              owner: from,
              nonce: nonce,
              methodName: methodName,
              signedCid: res,
              blockTime: now);
          StoreSignedMessage signData = StoreSignedMessage(
              time: now.toString(),
              message: sm,
              cid: res,
              pending: 1,
              nonce: sm.message.nonce);
          if (m == 0 || (m == 2 && isCreate)) {
            await OpenedBox.messageInsance.put(res, msgData);
          }
          OpenedBox.pushInsance.put(res, signData);
          addOperation(methodName);
          if (callback != null) {
            callback(res);
          }
        }
      } else {
        throw Exception(response.detail);
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        throw Exception('timeout');
      } else {
        throw (e);
      }
    } catch (e) {
      dismissAllToast();
      throw (e);
    }
  }

  void checkSpeedUpOrMakeNew(
      {@required BuildContext context,
      @required ValueChanged<bool> onNew,
      @required Noop onSpeedup,
      int nonce,
      String multiId = ''}) {
    bool shouldSpeed = false;
    shouldSpeed = OpenedBox.pushInsance.values
        .where((mes) =>
            mes.message.message.from == $store.wal.addressWithNet &&
            mes.nonce == nonce)
        .isNotEmpty;

    if (shouldSpeed) {
      showCustomModalBottomSheet(
          shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
          context: context,
          builder: (BuildContext context) {
            return ConstrainedBox(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 30),
                child: SpeedupSheet(
                  onNew: () {
                    onNew(true);
                  },
                  onSpeedUp: onSpeedup,
                ),
              ),
              constraints: BoxConstraints(maxHeight: 800),
            );
          });
    } else {
      onNew(false);
    }
  }

  TMessage getIncreaseGasMessage({int nonce}) {
    if (nonce == null) {
      nonce = $store.nonce;
    }

    var pushList = OpenedBox.pushInsance.values
        .where((mes) =>
            mes.from == $store.wal.addressWithNet && mes.nonce == nonce)
        .toList();
    if (pushList.isNotEmpty) {
      var last = pushList.last;
      var msg = last.message.message;
      var caculatePremium = (int.tryParse(msg.gasPremium) * 1.3).truncate();
      var chainFeeCap = int.tryParse(msg.gasFeeCap) ?? 0;
      msg.gasPremium = caculatePremium.toString();
      msg.gasFeeCap = max(chainFeeCap, caculatePremium + 100).toString();
      return msg;
    } else {
      throw Exception('get message fail');
    }
  }

  Future<void> speedup(
      {@required String private,
      String methodName = '',
      String multiId = ''}) async {
    TMessage msg;
    var isApprove = methodName == FilecoinMethod.approve;
    var isPropose = methodName == FilecoinMethod.propose;
    try {
      msg = getIncreaseGasMessage();
    } catch (e) {
      showCustomError('opFail'.tr);
      return '';
    }
    CacheMultiMessage multiMessage;
    MultiApproveMessage approveMessage;
    if (isPropose) {
      var list = OpenedBox.multiProposeInstance.values
          .where((mes) => mes.from == msg.from && mes.nonce == msg.nonce)
          .toList();
      if (list.isNotEmpty) {
        multiMessage = list[0];
      }
    }
    if (isApprove) {
      var list = OpenedBox.multiApproveInstance.values
          .where((mes) => mes.from == msg.from && mes.nonce == msg.nonce)
          .toList();
      if (list.isNotEmpty) {
        approveMessage = list[0];
      }
    }
    try {
      await sendMessage(
          message: msg,
          private: private,
          multiId: multiId,
          multiMessage: multiMessage,
          callback: (res) {
            var keys = OpenedBox.pushInsance.values
                .where((mes) => mes.nonce == msg.nonce && mes.from == msg.from)
                .toList();
            if (keys.isNotEmpty) {
              OpenedBox.pushInsance.delete(keys[0].cid);
            }
            if (isPropose && multiMessage != null) {
              multiMessage.cid = res;
              multiMessage.blockTime = getSecondSinceEpoch();
              OpenedBox.multiProposeInstance.put(res, multiMessage);
            }
            if (isApprove && approveMessage != null) {
              OpenedBox.multiApproveInstance.put(
                  res,
                  MultiApproveMessage(
                      from: approveMessage.from,
                      fee: msg.maxFee.toString(),
                      time: getSecondSinceEpoch(),
                      proposeCid: approveMessage.proposeCid,
                      cid: res,
                      txId: approveMessage.txId,
                      nonce: approveMessage.nonce));
            }
          });
    } catch (e) {
      throw (e);
    }
  }

  Future<bool> getGas({String to, String methodName = 'Send'}) async {
    to = to ?? $store.addr;
    try {
      var gas = await getGasDetail(to: to, methodName: methodName);
      $store.setGas(gas);
      $store.setChainGas(gas);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// get gas detail by to
  Future<Gas> getGasDetail({String to, String methodName = 'Send'}) async {
    to = to ?? $store.addr;
    try {
      var result = await client
          .get(feePath, queryParameters: {'method': methodName, 'actor': to});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        var res = response.data;
        var limit = res['gas_limit'] ?? 0;
        var premium = res['gas_premium'] ?? '100000';
        var feeCap = res['gas_cap'] ?? '0';
        var limitNum = limit;
        var premiumNum = int.tryParse(premium as String) ?? 0;
        var feeCapNum = int.tryParse(feeCap as String) ?? 0;
        var gas = Gas(
            feeCap: feeCapNum.toString(),
            gasLimit: limitNum as num,
            premium: premiumNum.toString());
        return gas;
      } else {
        throw Exception('get gas fail');
      }
    } catch (e) {
      throw Exception('get gas fail');
    }
  }

  /// get multi info by address
  Future<MultiWalletInfo> getMultiInfo(String addr) async {
    try {
      var result = await client.get(multiPath, queryParameters: {'address': addr});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        var res = response.data;
        var info = MultiWalletInfo(
            signerMap: {},
            balance: res['balance'] as String,
            robustAddress: res['address'] as String,
            approveRequired: res['approve_required'] as num);
        (res['signers'] as List).forEach((element) {
          var m = element as Map<String, dynamic>;
          m.entries.forEach((e) {
            info.signerMap[e.value as String] = e.key;
          });
        });
        return info;
      } else {
        throw Exception('get multisig fail');
      }
    } catch (e) {
      throw Exception('get multisig fail');
    }
  }

  /// get message detail
  Future<MessageDetail> getMessageDetail(String cid) async {
    try {
      var result = await client.get(pushPath, queryParameters: {'cid': cid});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        var res = response.data;
        var detail = MessageDetail.fromJson(res as Map<String, dynamic>);
        return detail;
      } else {
        throw Exception('get message detail fail');
      }
    } catch (e) {
      throw Exception('get message detail fail');
    }
  }

  /// prepare nonce
  Future<bool> prepareNonce(
      {num method, String to, String from, String methodName = 'Send'}) async {
    var wal = $store.wal;
    var address = wal.addressWithNet;
    to = to ?? address;
    try {
      var res = await getNonce(from ?? $store.addr);
      $store.setNonce(res);
      return true;
    } catch (e) {
      $store.setNonce(-1);
      return false;
    }
  }

  Future<int> getNonce(String addr) async {
    var nonce = 0;
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': addr});
      var response =
          FilecoinResponse.fromJson(res.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> data = response.data as Map<String, dynamic>;
          nonce = data['nonce'] as int;
        }
      } else {
        throw Exception("get nonce fail");
      }
    } catch (e) {
      throw Exception("get nonce fail");
    }
    return nonce;
  }

  Future<String> getBalance(String addr) async {
    var balance = '0';
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': addr});
      var response =
          FilecoinResponse.fromJson(res.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> data = response.data as Map<String, dynamic>;
          balance = data['balance'] as String;
        }
      } else {
        throw Exception("get balance fail");
      }
    } catch (e) {
      throw Exception("get balance fail");
    }
    return balance;
  }

  Future<BalanceNonce> getBalanceNonce(String addr) async {
    var balanceNonce = BalanceNonce();
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': addr});
      var response =
          FilecoinResponse.fromJson(res.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> data = response.data as Map<String, dynamic>;
          balanceNonce.balance = data['balance'] as String;
          balanceNonce.nonce = data['nonce'] as int;
        }
      } else {
        throw Exception("get balance fail");
      }
    } catch (e) {
      throw Exception("get balance fail");
    }
    return balanceNonce;
  }

  Future<List<Map<String, dynamic>>> getMessageList(
      {@required String actor,
      String direction = 'down',
      String mid = '',
      int limit = 20}) async {
    try {
      List<Map<String, dynamic>> list = [];
      var res = await client.get(messageListPath, queryParameters: {
        'actor': actor,
        'direction': direction,
        'mid': mid,
        'limit': limit
      });
      var response =
          FilecoinResponse.fromJson(res.data as Map<String, dynamic>);
      if (response.code != 200 && response.data != null) {
        throw Exception('get messages fail');
      } else {
        if (response.data != null &&
            response.data is Map &&
            response.data['messages'] is List) {
          list = (response.data['messages'] as List)
              .map((mes) => mes as Map<String, dynamic>)
              .toList();
        }
      }
      return list;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<TMessage> buildMessage(Map<String, dynamic> data) async {
    try {
      var result = await client.post(buildPath, data: data);
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        return TMessage.fromJson(
            response.data['message'] as Map<String, dynamic>);
      } else {
        throw Exception('build message fail');
      }
    } catch (e) {
      throw Exception('build message fail');
    }
  }

  Future<List<Map<String, dynamic>>> getMultiMessageList(
      {@required String actor,
      String direction = 'down',
      String mid = '',
      int limit = 20}) async {
    try {
      List<Map<String, dynamic>> list = [];
      var res = await client.get(proposePath, queryParameters: {
        'actor': actor,
        'direction': direction,
        'mid': mid,
        'limit': limit
      });
      var response =
          FilecoinResponse.fromJson(res.data as Map<String, dynamic>);
      if (response.code != 200 && response.data != null) {
        throw Exception('get messages fail');
      } else {
        if (response.data != null &&
            response.data is Map &&
            response.data['messages'] is List) {
          list = (response.data['messages'] as List)
              .map((mes) => mes as Map<String, dynamic>)
              .toList();
        }
      }
      return list;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CacheMultiMessage> getMultiMessageDetail(String cid) async {
    try {
      var result =
          await client.get(proposeDetailPath, queryParameters: {'cid': cid});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data is Map) {
        return CacheMultiMessage.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        throw Exception('get approves fail');
      }
    } catch (e) {
      throw Exception('get approves fail');
    }
  }

  Future<String> getAddressType(String addr) async {
    try {
      var result =
          await client.get(typePath, queryParameters: {'address': addr});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 &&
          response.data is Map &&
          response.data['type'] != null) {
        return response.data['type'] as String;
      } else {
        throw Exception('not exist');
      }
    } catch (e) {
      throw Exception('not exist');
    }
  }

  Future<MinerMeta> getMinerMeta(String addr) async {
    try {
      var result =
          await client.get(minerMetaPath, queryParameters: {'address': addr});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        return MinerMeta.fromMap(response.data as Map<String, dynamic>);
      } else {
        throw Exception('get miner meta fail');
      }
    } catch (e) {
      throw Exception('get miner meta fail');
    }
  }

  Future<MinerHistoricalStats> getMinerYesterdayInfo(String addr) async {
    try {
      var result =
          await client.get(minerPowerPath, queryParameters: {'address': addr});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        return MinerHistoricalStats.fromMap(
            response.data as Map<String, dynamic>);
      } else {
        throw Exception('get miner info fail');
      }
    } catch (e) {
      throw Exception('get miner info fail');
    }
  }

  Future<List<MinerAddress>> getMinerRelatedAddressBalance(String actor) async {
    try {
      var result = await client
          .get(minerRelatedAddressPath, queryParameters: {'address': actor});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 &&
          response.data != null &&
          response.data['balances'] is List) {
        return (response.data['balances'] as List).map((addr) {
          var res = MinerAddress.fromMap(addr as Map<String, dynamic>);
          res.miner = actor;
          return res;
        }).toList();
      } else {
        throw Exception('get miner balance fail');
      }
    } catch (e) {
      throw Exception('get miner balance fail');
    }
  }

  Future<MinerSelfBalance> getMinerBalanceInfo(String address) async {
    print(address);
    try {
      var result = await client
          .get(minerBalancePath, queryParameters: {'address': address});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        return MinerSelfBalance.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('get miner balance fail');
      }
    } catch (e) {
      throw Exception('get miner balance fail');
    }
  }

  Future<List<Map<String, dynamic>>> getMultiReceiveMessages(
      {@required String actor,
      String direction = 'down',
      String mid = '',
      int limit = 20}) async {
    try {
      List<Map<String, dynamic>> list = [];
      var res = await client.get(multiDepositPath, queryParameters: {
        'actor': actor,
        'direction': direction,
        'mid': mid,
        'limit': limit
      });
      var response =
          FilecoinResponse.fromJson(res.data as Map<String, dynamic>);
      if (response.code != 200 && response.data != null) {
        throw Exception('get messages fail');
      } else {
        if (response.data != null &&
            response.data is Map &&
            response.data['messages'] is List) {
          list = (response.data['messages'] as List)
              .map((mes) => mes as Map<String, dynamic>)
              .toList();
        }
      }
      return list;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<String>> getActiveMiners(String actor) async {
    try {
      var result =
          await client.get(minersPath, queryParameters: {'address': actor});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 &&
          response.data is Map &&
          response.data['miners'] is List) {
        return (response.data['miners'] as List)
            .map((ele) => ele['actor'] as String)
            .toList();
      } else {
        throw Exception('not exist');
      }
    } catch (e) {
      throw Exception('not exist');
    }
  }

  Future<String> getSerializeParams(Map<String, dynamic> data) async {
    try {
      var result = await client.post(serializePath, data: data);
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data is Map) {
        return response.data['param'] as String;
      } else {
        throw Exception('serialize params fail');
      }
    } catch (e) {
      throw Exception('serialize params fail');
    }
  }

  Future<Gas> estimateGas(Map<String, dynamic> data) async {
    try {
      var result = await client.post(buildPath, data: data);
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        var message =
            TMessage.fromJson(response.data['message'] as Map<String, dynamic>);
        return Gas(
            feeCap: message.gasFeeCap,
            gasLimit: message.gasLimit,
            premium: message.gasPremium);
      } else {
        throw Exception('estimate gas fail');
      }
    } catch (e) {
      throw Exception('estimate gas fail');
    }
  }

  Future<Map<String, dynamic>> decodeParams(Map<String, dynamic> data) async {
    try {
      var result = await client.post(decodeParamsPath, data: data);
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("decode params fail");
      }
    } catch (e) {
      throw Exception("decode params fail");
    }
  }

  /// get fil price
  Future<double> getFilPrice() async {
    double price;
    try {
      var result = await client
          .get(pricePath, queryParameters: {'id': 'filecoin', 'vs': 'usd'});
      var response =
          FilecoinResponse.fromJson(result.data as Map<String, dynamic>);
      if (response.code == 200 && response.data != null) {
        price = response.data as double;
      } else {
        price = 0;
        throw Exception("get fil price fail");
      }
    } catch (e) {
      price = 0;
      throw Exception("get fil price fail");
    }
    return price;
  }
}

String getErrorMessage(String message) {
  if (message.contains('nonce')) {
    return 'wrongNonce'.tr;
  } else if (message.contains('cap')) {
    return 'lowFeeCap'.tr;
  } else if (message.contains('signature')) {
    return 'wrongSignature'.tr;
  } else if (message.contains('funds')) {
    return 'errorLowBalance'.tr;
  } else {
    return message;
  }
}
