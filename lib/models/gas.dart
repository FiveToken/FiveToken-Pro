import 'package:fil/index.dart';

class Gas {
  String feeCap, premium, baseFee;
  num gasLimit, gasUsed;
  int level;
  Gas(
      {this.feeCap = '0',
      this.gasLimit = 0,
      this.premium = '0',
      this.gasUsed = 0,
      this.level = 0,
      this.baseFee = '0'});
  Gas.fromJson(Map<String, dynamic> json) {
    this.feeCap = json['feeCap'];
    this.gasLimit = json['gasLimit'];
    this.premium = json['premium'];
    this.gasUsed = json['gas_used'];
    this.baseFee = json['base_fee'];
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "feeCap": this.feeCap,
      "gasLimit": this.gasLimit,
      "premium": this.premium,
      "baseFee": this.baseFee,
      'gasUsed': this.gasUsed
    };
  }

  bool get valid => feeCap != '0';

  String get maxFee {
    try {
      return formatFil(feeNum.toString(), size: 5);
    } catch (e) {
      return '';
    }
  }

  BigInt get feeNum {
    try {
      return BigInt.from(gasLimit) * BigInt.parse(feeCap);
    } catch (e) {
      return BigInt.zero;
    }
  }

  String get attoFil {
    try {
      var v = (double.parse(feeCap) * gasLimit);
      return BigInt.from(v).toString();
    } catch (e) {
      return '0';
    }
  }
}
