import 'package:fil/index.dart';
import 'package:hive/hive.dart';
part 'cacheMessage.g.dart';

class MessageDetail {
  String to,
      from,
      value,
      gasPrice,
      params,
      gasFeeCap,
      gasPremium,
      minerTip,
      baseFeeBurn,
      blockCid,
      signedCid,
      methodName,
      allGasFee,
      overEstimationBurn;
  num version, nonce, gasLimit, method, blockTime, exitCode, pending, height;
  dynamic args;
  dynamic returns;
  MessageDetail(
      {this.to = '',
      this.from = '',
      this.value = '0',
      this.gasFeeCap = '0',
      this.gasPremium = '0',
      this.gasLimit = 0,
      this.minerTip = '0',
      this.baseFeeBurn = '0',
      this.overEstimationBurn = '0',
      this.allGasFee = '0',
      this.version,
      this.nonce,
      this.method,
      this.height,
      this.blockCid = '',
      this.args,
      this.methodName = '',
      this.returns,
      this.signedCid = ''});
  MessageDetail.fromJson(Map<String, dynamic> json)
      : this.version = json['version'],
        this.to = json['to'],
        this.from = json['from'],
        this.value = json['value'],
        this.gasPrice = json['gas_price'],
        this.gasLimit = json['gas_limit'],
        this.params = json['params'],
        this.nonce = json['nonce'],
        this.method = json['method'],
        this.methodName = json['method_name'],
        this.gasFeeCap = json['gas_fee_cap'],
        this.gasPremium = json['gas_premium'],
        this.minerTip = json['miner_tip'],
        this.baseFeeBurn = json['base_fee_burn'],
        this.overEstimationBurn = json['over_estimation_burn'],
        this.blockTime = json['block_time'],
        this.height = json['block_epoch'],
        this.signedCid = json['cid'],
        this.exitCode = json['exit_code'],
        this.allGasFee = json['gas_fee'] ?? '0',
        this.returns = jsonDecode(json['return_json'] ?? '{}'),
        this.args = jsonDecode(json['params_json'] ?? '{}');
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "to": this.to,
      "from": this.from,
      "value": this.value,
      "nonce": this.nonce,
    };
  }
}

@HiveType(typeId: 4)
class StoreMessage {
  @HiveField(0)
  String from;
  @HiveField(1)
  String to;
  @HiveField(2)
  String owner;
  @HiveField(3)
  String signedCid;
  @HiveField(4)
  String value;
  @HiveField(5)
  num blockTime;
  @HiveField(6)
  num exitCode;
  @HiveField(7)
  num pending;
  @HiveField(8)
  String args;
  @HiveField(9)
  String type;
  @HiveField(10)
  String multiParams;
  @HiveField(11)
  num nonce;
  @HiveField(12)
  String methodName;
  @HiveField(13)
  String mid;
  @HiveField(14)
  String multiMethod;

  StoreMessage(
      {this.from = '',
      this.to = '',
      this.signedCid = '',
      this.value = '0',
      this.blockTime,
      this.owner = '',
      this.pending = 1,
      this.args,
      this.type,
      this.multiParams,
      this.nonce,
      this.exitCode,
      this.multiMethod = '',
      this.methodName = ''});
  StoreMessage.fromJson(Map<dynamic, dynamic> json)
      : this.signedCid = json['cid'],
        this.to = json['to'],
        this.from = json['from'],
        this.value = json['value'],
        this.blockTime = json['block_time'],
        this.exitCode = json['exit_code'] ?? 0,
        this.owner = json['owner'],
        this.args = json['params_json'],
        this.pending = json['pending'],
        this.methodName = json['method_name'],
        this.nonce = json['nonce'],
        this.mid = json['mid'],
        this.multiMethod = json['mock'] ?? "";
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'signed_cid': this.signedCid,
      'to': this.to,
      'from': this.from,
      'value': this.value,
      'block_time': this.blockTime,
      'exit_code': this.exitCode,
      'pending': this.pending,
      'owner': this.owner,
      'args': this.args,
      'nonce': this.nonce,
      'multiParams': this.multiParams,
      'mid': mid
    };
  }
}

@HiveType(typeId: 15)
class StoreMultiMessage {
  @HiveField(0)
  String from;
  @HiveField(1)
  String to;
  @HiveField(2)
  String owner;
  @HiveField(3)
  String signedCid;
  @HiveField(4)
  String value;
  @HiveField(5)
  num blockTime;
  @HiveField(6)
  num exitCode;
  @HiveField(7)
  num pending;
  @HiveField(8)
  String type;
  @HiveField(9)
  String msigTo;
  @HiveField(10)
  String msigValue;
  @HiveField(11)
  String txnId;
  @HiveField(12)
  num msigRequired;
  @HiveField(13)
  num msigApproved;
  @HiveField(14)
  bool msigSuccess;
  @HiveField(15)
  String proposalCid;
  @HiveField(16)
  String methodName;
  @HiveField(17)
  int nonce;
  StoreMultiMessage(
      {this.from,
      this.to,
      this.signedCid,
      this.value,
      this.blockTime,
      this.owner,
      this.pending = 0,
      this.type,
      this.exitCode,
      this.msigTo,
      this.msigValue,
      this.txnId,
      this.msigRequired,
      this.msigApproved,
      this.proposalCid = '',
      this.methodName = '',
      this.nonce = 0,
      this.msigSuccess = false});
  StoreMultiMessage.fromJson(Map<dynamic, dynamic> json)
      : this.signedCid = json['signed_cid'],
        this.to = json['to'],
        this.from = json['from'],
        this.value = json['value'],
        this.blockTime = json['block_time'],
        this.exitCode = json['exit_code'] ?? 0,
        this.owner = json['owner'],
        this.pending = json['pending'],
        this.msigValue = json['msig_value'],
        this.msigApproved = json['msig_approved'],
        this.msigRequired = json['msig_required'],
        this.msigSuccess = json['msig_success'],
        this.methodName = json['method_name'],
        this.nonce = json['nonce'],
        this.msigTo = json['msig_to'];
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'signed_cid': this.signedCid,
      'to': this.to,
      'from': this.from,
      'value': this.value,
      'block_time': this.blockTime,
      'exit_code': this.exitCode,
      'pending': this.pending,
      'owner': this.owner,
      'msig_value': msigValue
    };
  }
}

@HiveType(typeId: 17)
class CacheMultiMessage {
  @HiveField(0)
  String cid;
  @HiveField(1)
  num blockTime;
  @HiveField(2)
  String from;
  @HiveField(3)
  String to;
  @HiveField(4)
  String status;
  @HiveField(5)
  String fee;
  @HiveField(6)
  String params;
  @HiveField(7)
  String method;
  @HiveField(8)
  String innerParams;
  @HiveField(9)
  int nonce;
  @HiveField(10)
  String owner;
  @HiveField(11)
  String mid;
  @HiveField(12)
  int pending;
  @HiveField(13)
  int exitCode;
  @HiveField(14)
  int txId;
  @HiveField(15)
  int type;
  @HiveField(16)
  String value;
  @HiveField(17)
  List<MultiApproveMessage> approves;
  CacheMultiMessage(
      {this.cid = '',
      this.blockTime = 0,
      this.from = '',
      this.to = '',
      this.status = '',
      this.fee = '0',
      this.method = '',
      this.innerParams = '',
      this.nonce = 0,
      this.owner = '',
      this.params = '{}',
      this.mid = '',
      this.pending = 1,
      this.txId = 0,
      this.value = '0',
      this.approves = const [],
      this.type = 0, // 0 propose 1 send
      this.exitCode = 0});
  CacheMultiMessage.fromJson(Map<dynamic, dynamic> json) {
    this.cid = json['cid'] ?? '';
    this.blockTime = json['block_time'] ?? 0;
    this.to = json['to'] ?? "";
    this.from = json['from'] ?? '';
    this.status = json['status'] ?? '';
    this.fee = json['gas_fee'] ?? '0';
    this.params = json['params_json'];
    this.method = json['params_method'] ?? '';
    this.innerParams = json['params_params'];
    this.owner = json['owner'] ?? '';
    this.nonce = json['nonce'] ?? 0;
    this.mid = json['mid'] ?? '';
    this.txId = json['params_txnid'] ?? 0;
    this.exitCode = json['exit_code'] ?? 0;
    this.value = json['value'] ?? '0';
    if (json['approves'] != null && json['approves'] is List) {
      this.approves = (json['approves'] as List)
          .map((app) => MultiApproveMessage.fromJson(app))
          .toList();
    } else {
      this.approves = [];
    }
  }

  Map<String, dynamic> get decodeParams {
    try {
      var p = jsonDecode(params);
      return p;
    } catch (e) {
      return {'To': '', 'Value': '0'};
    }
  }

  dynamic get decodeInnerParams {
    try {
      var p = jsonDecode(innerParams);
      return p;
    } catch (e) {
      return innerParams;
    }
  }

  bool get completed => pending == 0;
}

@HiveType(typeId: 18)
class MultiApproveMessage {
  @HiveField(0)
  String from;
  @HiveField(1)
  String fee;
  @HiveField(2)
  num time;
  @HiveField(3)
  int nonce;
  @HiveField(4)
  int exitCode;
  @HiveField(5)
  int pending;
  @HiveField(6)
  String proposeCid;
  @HiveField(7)
  String cid;
  @HiveField(8)
  int txId;
  MultiApproveMessage(
      {this.from = '',
      this.fee = '0',
      this.time = 0,
      this.nonce = 0,
      this.exitCode = 0,
      this.proposeCid = '',
      this.cid = '',
      this.txId = 0,
      this.pending = 1});
  MultiApproveMessage.fromJson(Map<String, dynamic> json) {
    this.from = json['from'];
    this.fee = json['gas_fee'];
    this.time = json['block_time'];
    this.nonce = json['nonce'];
    this.cid = json['cid'];
    this.exitCode = json['exit_code'];
  }
}
