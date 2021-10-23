import 'package:fil/index.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

DioAdapter mockProvider() {
  var dioAdapter = DioAdapter();
  var dio = Dio();
  dio.httpClientAdapter = dioAdapter;
  var provider = FilecoinProvider(httpClient: dio);
  Global.provider = provider;
  return dioAdapter;
}
