import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';

class FilecoinResponse {
  int code;
  dynamic data;
  String message;
  String detail;
  FilecoinResponse({this.code, this.data, this.message, this.detail});
  FilecoinResponse.fromJson(Map<String, dynamic> map) {
    code = map['code'];
    data = map['data'];
    message = map['message'];
    detail = map['detail'];
  }
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
  static String clientId = ClientID;
  static String baseUrl = 'https://api.fivetoken.io/api/$clientId';
  FilecoinProvider({Dio httpClient}) {
    client = httpClient ?? Dio();
    if (httpClient == null) {
      client.options.baseUrl = baseUrl;
      client.options.connectTimeout = 30000;
      client.interceptors.add(InterceptorsWrapper(onRequest: (options) {
        options.headers.addAll({
          'X-Client-Info': jsonEncode({
            'platform': Global.platform,
            'version': Global.version,
            'uuid': Global.uuid
          }),
        });
      }));
    }
  }
  Future<String> getActorId(String addr) async {
    try {
      var result = await client.get(idPath, queryParameters: {"address": addr});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception('get actor id fail');
      }
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future sendSignedMessage(
    Map<String, dynamic> message, {
    SingleParamCallback<String> callback,
  }) async {
    showCustomLoading('sending'.tr);
    var result = await client
        .post(pushPath, data: {'cid': '', 'raw': jsonEncode(message)});
    dismissAllToast();
    var response = FilecoinResponse.fromJson(result.data);
    if (response.code == 200 && response.data != null) {
      showCustomToast('tradeSucc'.tr);
      var res = response.data;
      if (callback != null) {
        callback(res);
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
    SingleParamCallback<String> callback,
    bool increaseNonce = false,
    CacheMultiMessage multiMessage,
  }) async {
    try {
      String sign = '';
      num signType;
      if (increaseNonce) {
        var nonce = message.nonce;
        OpenedBox.pushInsance.values
            .where((mes) => mes.from == $store.wal.addrWithNet)
            .forEach((mes) {
          if (mes.nonce != null && mes.nonce > nonce) {
            nonce = mes.nonce;
          }
        });
        message.nonce = nonce + 1;
      }
      var cid = await Flotus.messageCid(msg: jsonEncode(message));
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
      String res = '';
      showCustomLoading('sending'.tr);
      var result = await client.post(pushPath,
          data: {'cid': cid, 'raw': jsonEncode(sm.toLotusSignedMessage())});
      dismissAllToast();
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        if (response.data is String && response.data != '') {
          showCustomToast('tradeSucc'.tr);
          res = response.data;
          var cacheGas = CacheGas(
              cid: res,
              feeCap: message.gasFeeCap,
              gasLimit: message.gasLimit,
              premium: message.gasPremium);
          OpenedBox.gasInsance.put('$from\_$nonce', cacheGas);
          $store.setGas(Gas());
          $store.setNonce(-1);
          var now = getSecondSinceEpoch();
          var m = message.method;
          var isCreate = message.to == FilecoinAccount.f01;
          if (m == 0 || (m == 2 && isCreate)) {
            await OpenedBox.messageInsance.put(
                res,
                StoreMessage(
                    pending: 1,
                    from: from,
                    to: to,
                    value: value,
                    owner: from,
                    nonce: nonce,
                    methodName: methodName,
                    signedCid: res,
                    blockTime: now));
          }
          OpenedBox.pushInsance.put(
              res,
              StoreSignedMessage(
                  time: now.toString(),
                  message: sm,
                  cid: res,
                  pending: 1,
                  nonce: sm.message.nonce));
          OpenedBox.nonceInsance.put(
              from,
              Nonce(
                  value: nonce + 1,
                  time: DateTime.now().millisecondsSinceEpoch));
          if (callback != null) {
            callback(res);
          }
        }
      } else {
        throw Exception(response.detail);
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        throw Exception('timeout');
      } else {
        throw (e);
      }
    } catch (e) {
      dismissAllToast();
      print(e);
      throw (e);
    }
  }

  void checkSpeedUpOrMakeNew(
      {@required BuildContext context,
      @required SingleParamCallback<bool> onNew,
      @required Noop onSpeedup,
      int nonce,
      String multiId = ''}) {
    bool shouldSpeed = false;
    shouldSpeed = OpenedBox.pushInsance.values
        .where((mes) =>
            mes.message.message.from == $store.wal.addrWithNet &&
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

  TMessage getIncreaseGasMessage({Gas gas, int nonce}) {
    if (nonce == null) {
      nonce = $store.nonce;
    }

    var pushList = OpenedBox.pushInsance.values
        .where(
            (mes) => mes.from == $store.wal.addrWithNet && mes.nonce == nonce)
        .toList();
    if (pushList.isNotEmpty) {
      var last = pushList.last;
      var msg = last.message.message;
      var caculatePremium = (int.tryParse(msg.gasPremium) * 1.3).truncate();
      var chainPremium =
          int.tryParse(gas != null ? gas.premium : msg.gasPremium) ?? 0;
      var chainFeeCap =
          int.tryParse(gas != null ? gas.feeCap : msg.gasFeeCap) ?? 0;
      var realPremium = max(chainPremium, caculatePremium);
      msg.gasPremium = realPremium.toString();
      msg.gasFeeCap = max(chainFeeCap, realPremium + 100).toString();
      return msg;
    } else {
      throw Exception('get message fail');
    }
  }

  Future<void> speedup(
      {@required String private,
      @required Gas gas,
      String methodName = '',
      String multiId = ''}) async {
    TMessage msg;
    var isApprove = methodName == FilecoinMethod.approve;
    var isPropose = methodName == FilecoinMethod.propose;
    try {
      msg = getIncreaseGasMessage(gas: gas);
    } catch (e) {
      print(e);
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
      print(e);
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

  Future<Gas> getGasDetail({String to, String methodName = 'Send'}) async {
    to = to ?? $store.addr;
    try {
      var result = await client
          .get(feePath, queryParameters: {'method': methodName, 'actor': to});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        var res = response.data;
        var limit = res['gas_limit'] ?? 0;
        var premium = res['gas_premium'] ?? '100000';
        var feeCap = res['gas_cap'] ?? '0';
        var limitNum = limit;
        var premiumNum = int.tryParse(premium) ?? 0;
        var feeCapNum = int.tryParse(feeCap) ?? 0;
        var gas = Gas(
            feeCap: feeCapNum.toString(),
            gasLimit: limitNum,
            premium: premiumNum.toString());
        return gas;
      } else {
        throw Exception('get gas fail');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<MultiWalletInfo> getMultiInfo(String addr) async {
    try {
      var result =
          await client.get(multiPath, queryParameters: {'address': addr});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        var res = response.data;
        var info = MultiWalletInfo(
            signerMap: {},
            balance: res['balance'],
            robustAddress: res['address'],
            approveRequired: res['approve_required']);
        (res['signers'] as List).forEach((element) {
          var m = element as Map<String, dynamic>;
          m.entries.forEach((e) {
            info.signerMap[e.value] = e.key;
          });
        });
        return info;
      } else {
        throw Exception('get multisig fail');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<MessageDetail> getMessageDetail(String cid) async {
    try {
      var result = await client.get(pushPath, queryParameters: {'cid': cid});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        var res = response.data;
        var detail = MessageDetail.fromJson(res);
        return detail;
      } else {
        throw Exception('get message detail fail');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<bool> getNonceAndGas(
      {num method, String to, String from, String methodName = 'Send'}) async {
    var wal = $store.wal;
    var address = wal.addrWithNet;
    to = to ?? address;
    try {
      var res = await Future.wait([
        getNonce(from ?? $store.addr),
        getGas(to: to, methodName: methodName)
      ]);
      if (res[0] != -1 && (res[1] as bool) == true) {
        var nonce = res[0] as int;
        $store.setNonce(nonce);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<int> getNonce(String addr) async {
    var nonce = 0;
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': addr});
      var response = FilecoinResponse.fromJson(res.data);
      if (response.code == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> data = response.data;
          nonce = data['nonce'];
        }
      } else {
        throw Exception("get nonce fail");
      }
    } catch (e) {
      throw Exception(e);
    }
    return nonce;
  }

  Future<String> getBalance(String addr) async {
    var balance = '0';
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': addr});
      var response = FilecoinResponse.fromJson(res.data);
      if (response.code == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> data = response.data;
          balance = data['balance'];
        }
      } else {
        throw Exception("get balance fail");
      }
    } catch (e) {
      throw Exception(e);
    }
    return balance;
  }

  Future<BalanceNonce> getBalanceNonce(String addr) async {
    var balanceNonce = BalanceNonce();
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': addr});
      var response = FilecoinResponse.fromJson(res.data);
      if (response.code == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> data = response.data;
          balanceNonce.balance = data['balance'];
          balanceNonce.nonce = data['nonce'];
        }
      } else {
        throw Exception("get balance fail");
      }
    } catch (e) {
      throw Exception(e);
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
      var response = FilecoinResponse.fromJson(res.data);
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
      print(e);
      throw Exception(e);
    }
  }

  Future<TMessage> buildMessage(Map<String, dynamic> data) async {
    try {
      var result = await client.post(buildPath, data: data);
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        return TMessage.fromJson(response.data['message']);
      } else {
        throw Exception('build message fail');
      }
    } catch (e) {
      throw (e);
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
      var response = FilecoinResponse.fromJson(res.data);
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
      print(e);
      throw Exception(e);
    }
  }

  Future<CacheMultiMessage> getMultiMessageDetail(String cid) async {
    try {
      var result =
          await client.get(proposeDetailPath, queryParameters: {'cid': cid});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data is Map) {
        return CacheMultiMessage.fromJson(response.data);
      } else {
        throw Exception('get approves fail');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<String> getAddressType(String addr) async {
    try {
      var result =
          await client.get(typePath, queryParameters: {'address': addr});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 &&
          response.data is Map &&
          response.data['type'] != null) {
        return response.data['type'];
      } else {
        throw Exception('not exist');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<MinerMeta> getMinerMeta(String addr) async {
    try {
      var result =
          await client.get(minerMetaPath, queryParameters: {'address': addr});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        return MinerMeta.fromMap(response.data);
      } else {
        throw Exception('get miner meta fail');
      }
    } catch (e) {
      print(e);
      throw (e);
    }
  }

  Future<MinerHistoricalStats> getMinerYesterdayInfo(String addr) async {
    try {
      var result =
          await client.get(minerPowerPath, queryParameters: {'address': addr});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        return MinerHistoricalStats.fromMap(response.data);
      } else {
        throw Exception('get miner info fail');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<List<MinerAddress>> getMinerRelatedAddressBalance(String actor) async {
    try {
      var result = await client
          .get(minerRelatedAddressPath, queryParameters: {'address': actor});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 &&
          response.data != null &&
          response.data['balances'] is List) {
        return (response.data['balances'] as List).map((addr) {
          var res = MinerAddress.fromMap(addr);
          res.miner = actor;
          return res;
        }).toList();
      } else {
        throw Exception('get miner balance fail');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<MinerSelfBalance> getMinerBalanceInfo(String address) async {
    try {
      var result = await client
          .get(minerBalancePath, queryParameters: {'address': address});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data != null) {
        return MinerSelfBalance.fromJson(response.data);
      } else {
        throw Exception('get miner balance fail');
      }
    } catch (e) {
      throw (e);
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
      var response = FilecoinResponse.fromJson(res.data);
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
      print(e);
      throw Exception(e);
    }
  }

  Future<List<String>> getActiveMiners(String actor) async {
    try {
      var result =
          await client.get(minersPath, queryParameters: {'address': actor});
      var response = FilecoinResponse.fromJson(result.data);
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
      throw (e);
    }
  }

  Future<String> getSerializeParams(Map<String, dynamic> data) async {
    try {
      var result = await client.post(serializePath, data: data);
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200 && response.data is Map) {
        return response.data['param'];
      } else {
        throw Exception('serialize params fail');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
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
