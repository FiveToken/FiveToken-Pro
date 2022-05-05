import 'package:fil/models/gas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var gasJson = {
    "feeCap": '0',
    "gasLimit": 0,
    "premium": '0',
    "base_fee": '0',
    "gas_used": 0
  };
  Gas gas = Gas.fromJson(gasJson);
  Map<String, dynamic> resGas = gas.toJson();
  Map<String, dynamic> expectGas = {
    "feeCap": '0',
    "gasLimit": 0,
    "premium": '0',
    "baseFee": '0',
    'gasUsed': 0
  };
  test("generate config connectTimeout", () async {
    expect(resGas, expectGas);
    bool valid = gas.valid;
    expect(valid, false);
    expect(gas.maxFee, '0 FIL');
    expect(gas.feeNum, BigInt.from(0) * BigInt.parse('0'));
    expect(gas.attoFil, BigInt.from(0).toString());
  });
}
