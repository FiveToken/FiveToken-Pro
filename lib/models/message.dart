import 'package:hive/hive.dart';
import 'gas.dart';
part 'message.g.dart';

@HiveType(typeId: 1)
class TMessage {
  @HiveField(0)
  String to;
  @HiveField(1)
  String from;
  @HiveField(2)
  String value;
  @HiveField(3)
  String gasFeeCap;
  @HiveField(4)
  String params;
  @HiveField(5)
  String gasPremium;
  @HiveField(6)
  num version;
  @HiveField(7)
  num nonce;
  @HiveField(8)
  num method;
  @HiveField(9)
  num gasLimit;
  @HiveField(10)
  String args;
  String innerArgs;

  TMessage(
      {this.version = 0,
      this.to = '',
      this.from = '',
      this.value = '0',
      this.gasFeeCap = '0',
      this.gasPremium = '0',
      this.gasLimit = 0,
      this.params = '',
      this.nonce = -1,
      this.args,
      this.innerArgs,
      this.method = 0});

  TMessage.fromJson(Map<String, dynamic> json)
      : this.version = json['Version'] as int,
        this.to = json['To'] as String,
        this.from = json['From'] as String,
        this.value = json['Value'] as String,
        this.gasFeeCap = json['GasFeeCap'] as String,
        this.gasLimit = json['GasLimit'] as num,
        this.gasPremium = json['GasPremium'] as String,
        this.params = json['Params'] as String,
        this.nonce = json['Nonce'] as num,
        this.args = json['Args'] as String,
        this.innerArgs = json['InnerArgs'] as String,
        this.method = json['Method'] as num;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Version": this.version,
      "To": this.to,
      "From": this.from,
      "Value": this.value,
      "GasFeeCap": this.gasFeeCap,
      "GasPremium": this.gasPremium,
      "GasLimit": this.gasLimit,
      "Params": this.params,
      "Nonce": this.nonce,
      "Method": this.method,
      "Args": this.args,
      "InnerArgs": this.innerArgs
    };
  }

  bool get valid {
    try {
      num.parse(gasFeeCap);
      num.parse(gasPremium);
      num.parse(value);
      return version is int &&
          to is String &&
          from is String &&
          gasLimit is num &&
          nonce is int &&
          method is int;
    } catch (e) {
      return false;
    }
  }

  BigInt get maxFee {
    var capNum = BigInt.tryParse(gasFeeCap) ?? BigInt.zero;
    var limit = BigInt.from(gasLimit);
    return capNum * limit;
  }

  Map<String, dynamic> toLotusMessage() {
    return <String, dynamic>{
      "Version": this.version,
      "To": this.to,
      "From": this.from,
      "Value": this.value,
      "GasFeeCap": this.gasFeeCap,
      "GasPremium": this.gasPremium,
      "GasLimit": this.gasLimit,
      "Params": this.params,
      "Nonce": this.nonce,
      "Method": this.method,
    };
  }

  void setGas(Gas gas) {
    gasFeeCap = gas.feeCap;
    gasLimit = gas.gasLimit;
    gasPremium = gas.premium;
  }

  Gas get gas =>
      Gas(gasLimit: gasLimit, feeCap: gasFeeCap, premium: gasPremium);
}

@HiveType(typeId: 2)
class Signature {
  @HiveField(0)
  String data;
  @HiveField(1)
  num type;

  Signature(this.type, this.data);

  Signature.fromJson(Map<String, dynamic> json)
      : this.type = json['Type'] as num,
        this.data = json['Data'] as String;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Type": this.type,
      "Data": this.data,
    };
  }
}

@HiveType(typeId: 0)
class SignedMessage {
  @HiveField(0)
  TMessage message;
  @HiveField(1)
  Signature signature;

  SignedMessage(this.message, this.signature);

  SignedMessage.fromJson(Map<String, dynamic> json)
      : this.message =
            TMessage.fromJson(json['Message'] as Map<String, dynamic>),
        this.signature =
            Signature.fromJson(json['Signature'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Message": this.message,
      "Signature": this.signature,
    };
  }

  Map<String, dynamic> toLotusSignedMessage() {
    return <String, dynamic>{
      "Message": this.message.toLotusMessage(),
      "Signature": this.signature.toJson(),
    };
  }
}

@HiveType(typeId: 7)
class StoreUnsignedMessage {
  @HiveField(0)
  TMessage message;
  @HiveField(1)
  String time;
  StoreUnsignedMessage({this.message, this.time});
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'message': message, 'time': time};
  }
}

@HiveType(typeId: 8)
class StoreSignedMessage {
  @HiveField(0)
  SignedMessage message;
  @HiveField(1)
  String time;
  @HiveField(2)
  num pending;
  @HiveField(3)
  String cid;
  @HiveField(4)
  num nonce;
  StoreSignedMessage(
      {this.message, this.time, this.pending = 0, this.cid, this.nonce});
  Map<String, dynamic> toJson() {
    return <String, dynamic>{"message": message, "time": time};
  }

  String get from => message.message.from;
  String get to => message.message.to;
}
