import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:fil/repository/http/interceptors.dart';

final http = Http();

class Http extends DioForNative {
  static Http instance;

  factory Http() {
    return instance ??= Http._().._init();
  }

  Http._();

  _init() async {
    ///Custom jsonDecodeCallback
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJson;

    options.connectTimeout = Timeout.medium;
    options.receiveTimeout = Timeout.medium;

    interceptors.add(HttpInterceptors());
  }
}

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}
