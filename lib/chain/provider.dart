import 'package:fil/index.dart';

class FilecoinProvider {
  static Future<String> sendMessage(
      {@required TMessage message,
      @required String private,
      String multiId = '',
      String methodName = 'transfer',
      String multiTo,
      String multiValue}) async {
    String sign = '';
    num signType;
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
    // return '';
    String res = await pushSignedMsg(sm.toLotusSignedMessage());
    if (res != '') {
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
        Hive.box<StoreMessage>(messageBox).put(
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
      if ([2, 3].contains(message.method) && !isCreate) {
        OpenedBox.multiMesInsance.put(
            res,
            StoreMultiMessage(
                pending: 1,
                from: from,
                to: multiId,
                value: '0',
                owner: from,
                nonce: nonce,
                msigTo: multiTo ?? multiId,
                msigValue: multiValue ?? '0',
                signedCid: res,
                type: message.method == 2 ? 'proposal' : 'approval',
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
      OpenedBox.nonceInsance.put(from,
          Nonce(value: nonce + 1, time: DateTime.now().millisecondsSinceEpoch));
      return res;
    } else {
      // showCustomError('sendFail'.tr);
      return '';
    }
  }

  static void checkSpeedUpOrMakeNew(
      {@required BuildContext context,
      @required Noop onNew,
      @required Noop onSpeedup,
      String multiId = ''}) {
    bool shouldSpeed = false;
    shouldSpeed = OpenedBox.pushInsance.values
        .where((mes) => mes.message.message.from == $store.wal.addrWithNet)
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
                  onNew: onNew,
                  onSpeedUp: onSpeedup,
                ),
              ),
              constraints: BoxConstraints(maxHeight: 800),
            );
          });
    } else {
      onNew();
    }
  }

  static TMessage getIncreaseGasMessage({Gas gas}) {
    var pushList = OpenedBox.pushInsance.values
        .where((mes) => mes.from == $store.wal.addrWithNet)
        .toList();
    pushList.sort((a, b) {
      if (a.nonce != null && b.nonce != null) {
        return b.nonce.compareTo(a.nonce);
      } else {
        return -1;
      }
    });
    var last = pushList.last;
    var msg = last.message.message;
    var caculatePremium = (int.parse(msg.gasPremium) * 1.3).truncate();
    var chainPremium = int.parse(gas != null ? gas.premium : msg.gasPremium);
    var realPremium = max(chainPremium, caculatePremium);
    msg.gasPremium = realPremium.toString();
    msg.gasFeeCap = (realPremium + 100).toString();
    return msg;
  }

  static Future<String> speedup(
      {@required String private,
      @required Gas gas,
      String multiId = ''}) async {
    var msg = getIncreaseGasMessage(gas: gas);
    var res = await FilecoinProvider.sendMessage(
        message: msg, private: private, multiId: multiId);
    if (res != '') {
      /// replace old push message
      var keys = OpenedBox.pushInsance.values
          .where((mes) => mes.nonce == msg.nonce)
          .toList();
      if (keys.isNotEmpty) {
        OpenedBox.pushInsance.delete(keys[0].cid);
      }
    }
    return res;
  }

  static Future<bool> getGas({num method = 0, String to}) async {
    to = to ?? $store.wal.addrWithNet;
    var res = await getGasDetail(method: method, to: to);
    if (res.feeCap != '0') {
      $store.setGas(res);
      $store.setChainGas(res);
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> getNonceAndGas(
      {num method, String to, String from}) async {
    var nonceBoxInstance = OpenedBox.nonceInsance;
    var wal = $store.wal;
    var address = wal.addrWithNet;
    to = to ?? address;
    var now = getSecondSinceEpoch();
    try {
      var res = await Future.wait([
        getNonce(from ?? $store.wal.addrWithNet),
        FilecoinProvider.getGas(method: method, to: to)
      ]);
      print(res[0]);
      if (res[0] != -1 && (res[1] as bool) == true) {
        var nonce = res[0] as int;
        if (!nonceBoxInstance.containsKey(address)) {
          await nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
        } else {
          Nonce nonceInfo = nonceBoxInstance.get(address);
          var interval = 5 * 60 * 1000;
          if (now - nonceInfo.time > interval) {
            nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
          }
        }
        var realNonce = max(nonce, nonceBoxInstance.get(address).value);
        $store.setNonce(realNonce);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
