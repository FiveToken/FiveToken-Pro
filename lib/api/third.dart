import 'package:fil/index.dart';

const _url = 'http://8.209.219.115:8090';

/// get fil price
Future<FilPrice> getFilPrice() async {
  try {
    var url = _url;
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
