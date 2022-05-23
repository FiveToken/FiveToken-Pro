import 'package:flutter_test/flutter_test.dart';
import 'package:fil/models/cacheMessage.dart';

void main() {
  test("generate model StoreMessage", () async {
    var messageDetail = MessageDetail.fromJson({
      'version': 1,
      'to': '',
      'from': '',
      'value': '',
      'gas_price': '',
      'gas_limit': 0,
      'params': '',
      'nonce': 1,
      'method': 0,
      'method_name': '',
      'gas_fee_cap': '',
      'gas_premium': '',
      'miner_tip': '',
      'base_fee_burn': '',
      'over_estimation_burn': '',
      'block_time': 1,
      'block_epoch': 1,
      'cid': '',
      'exit_code': 1,
      'gas_fee': '',
      'return_json': '{}',
      'params_json': '{}'
    });
    var messageDetail1 = messageDetail.toJson();
    expect(messageDetail.gasLimit, 0);

    var messageDetail2 = MessageDetail(
      to: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
      from: 'f16wkgzlglyejqlougingwbnztnp7lrh2xgzlbviq',
      value: '10000000000',
      gasPremium:'129994',
      gasFeeCap: '1904238986',
      gasLimit: 790835,
      allGasFee: '52295069132040',
      methodName: 'Send',
      nonce: 631,
      height: 1697566
    );
    expect(messageDetail2.nonce, 631);
    var json = {
      "gasPrice": '0',
      "gasFeeCap": '0',
      "gasPremium": '0',
      'cid': '',
      'to': '',
      'from': '',
      'value': '',
      'blockTime': 0,
      'exitCode': 0,
      'pending': 0,
      'nonce': 0,
      'args': {},
    };
    var storeMes = StoreMessage.fromJson(json);
    var res1 = storeMes.toJson();
    expect(storeMes.pending, 0);

    var storeMultiMessage = StoreMultiMessage.fromJson({
      'signed_cid': '',
      'to': '',
      'from': '',
      'value': '',
      'block_time': 1,
      'exit_code': 1,
      'owner': '',
      'pending': 1,
      'msig_value': '',
      'msig_approved': 1,
      'msig_required': 1,
      'msig_success': false,
      'method_name': '',
      'nonce': 1,
      'msig_to': ''
    });
    var storeMultiMessage1 = storeMultiMessage.toJson();
    expect(storeMultiMessage.pending, 1);

    var cacheMultiMessage = CacheMultiMessage.fromJson({
      'cid': '',
      'block_time': 0,
      'to': '',
      'from': '',
      'status': '',
      'gas_fee': '',
      'params_json': '',
      'params_method': '',
      'params_params': '',
      'owner': '',
      'nonce': 1,
      'params_txnid': 1,
      'exit_code': 0,
      'value': '',
      'approves': [],
    });
    var cacheMultiMessage1 = CacheMultiMessage.fromJson({
      'cid':'',
      'block_time':0,
      'to':'',
      'from':'',
      'status':'',
      'gas_fee':'',
      'params_json':'',
      'params_method':'',
      'params_params':'',
      'owner':'',
      'nonce':1,
      'params_txnid':1,
      'exit_code':0,
      'value':'',
      'approves':null,
    });
    var decodeParams = cacheMultiMessage.decodeParams;
    var decodeInnerParams = cacheMultiMessage.decodeInnerParams;
    var completed = cacheMultiMessage.completed;
    var cacheMultiMessage2 = CacheMultiMessage(from: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema');
    expect(cacheMultiMessage.nonce, 1);
    expect(cacheMultiMessage2.from, 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema');
    expect(cacheMultiMessage1.approves, []);
    var multiApproveMessage = MultiApproveMessage.fromJson({
      'from': '',
      'gas_fee': '',
      'block_time': 0,
      'nonce': 1,
      'cid': '',
      'exit_code': 0,
    });
    var MultiApproveMessage1 = MultiApproveMessage(from:'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema');
    expect(multiApproveMessage.nonce, 1);

    expect(MultiApproveMessage1.from, 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema');

    var StoreMultiMessage2 = StoreMultiMessage(
        from:'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
        to:'f16wkgzlglyejqlougingwbnztnp7lrh2xgzlbviq'
    );
    expect(StoreMultiMessage2.from, 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema');

  });
}
