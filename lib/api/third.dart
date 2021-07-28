import 'package:fil/index.dart';

Future<FilPrice> getFilPrice() async {
  try {
    var url=apiMap[mode];
    var response = await Dio().get('$url/third/price');
    if (response.data['code'] == 0) {
      return FilPrice.fromJson(response.data['data']);
    } else {
      return FilPrice();
    }
  } catch (e) {
    print(e);
    return FilPrice();
  }
}