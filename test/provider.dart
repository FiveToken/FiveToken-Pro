import 'package:dio/dio.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/common/global.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

DioAdapter mockProvider() {
  String baseUrl = 'https://apibwwc1FZLnJ80.xyz/api/7om8n3ri4v23pjjfs4ozctlb';
  var dio = Dio(BaseOptions(baseUrl: baseUrl));
  var dioAdapter = DioAdapter(dio: dio);
  dio.httpClientAdapter = dioAdapter;
  var provider = FilecoinProvider(httpClient: dio);
  Global.provider = provider;
  return dioAdapter;
}
