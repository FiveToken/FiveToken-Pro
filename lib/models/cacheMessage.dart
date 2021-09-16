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
        this.height = json['height'],
        this.signedCid = json['signed_cid'],
        this.exitCode = json['exit_code'],
        this.allGasFee = json['all_gas_fee'],
        this.returns = json['returns'],
        this.args = json['args'];
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
      this.methodName = ''});
  StoreMessage.fromJson(Map<dynamic, dynamic> json)
      : this.signedCid = json['signed_cid'],
        this.to = json['to'],
        this.from = json['from'],
        this.value = json['value'],
        this.blockTime = json['block_time'],
        this.exitCode = json['exit_code'] ?? 0,
        this.owner = json['owner'],
        this.args = jsonEncode(json['args']),
        this.pending = json['pending'],
        this.methodName = json['method_name'],
        this.nonce = json['nonce'];
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
      'multiParams': this.multiParams
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
