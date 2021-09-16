import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';

/// get nonce of an address
Future<int> getNonce(String addr) async {
  var rs = await fetch("filscan.BalanceNonceByAddress", [
    {"address": addr},
  ]);
  if (rs == null) {
    return -1;
  }
  var res = JsonRPCResponse.fromJson(rs.data);
  if (res.error != null) {
    var error = JsonRPCError.fromJson(res.error);
    print(error.message);
    return -1;
  }
  var r = -1;
  if (res.result != null) {
    var result = res.result as Map<String, dynamic>;
    r = result["nonce"];
  }
  return r == null ? -1 : r;
}

/// get balance and nonce of an address
Future<BalanceNonce> getBalance(String address) async {
  var rs = await fetch("filscan.BalanceNonceByAddress", [
    {"address": address},
  ]);
  var balanceNonce = BalanceNonce();
  if (rs == null) {
    return balanceNonce;
  }
  var res = JsonRPCResponse.fromJson(rs.data);
  if (res.error != null) {
    var error = JsonRPCError.fromJson(res.error);
    print(error.message);
    return balanceNonce;
  }

  if (res.result != null) {
    var result = res.result as Map<String, dynamic>;
    balanceNonce.balance = result["balance"];
    balanceNonce.nonce = result["nonce"] as num;
  }
  return balanceNonce;
}
/// get actor id of an address
Future<String> getAddressActor(String address) async {
  try {
    var result = await fetch(
      "filscan.ActorById",
      [address],
    );
    var response = JsonRPCResponse.fromJson(result.data);
    if (response.error != null) {
      showCustomError(response.error['message']);
      return '';
    } else {
      var res = response.result;
      if (res != null) {
        var basic = res['basic'] ?? {};
        return basic['actor'];
      } else {
        return '';
      }
    }
  } catch (e) {
    return '';
  }
}

///get multi-sig account info by actor id
Future<MultiWalletInfo> getMultiInfo(String id) async {
  var empty = MultiWalletInfo();
  try {
    var result = await fetch("filscan.MsigAddressState", [id]);

    if (result.data == null) {
      return empty;
    }
    var response = JsonRPCResponse.fromJson(result.data);

    if (response.error != null) {
      return empty;
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
        return empty;
      }
    } else {
      return empty;
    }
  } catch (e) {
    dismissAllToast();
    return empty;
  }
}