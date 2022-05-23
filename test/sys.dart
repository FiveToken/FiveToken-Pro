import 'package:flutter/services.dart';
import 'package:flutter_test/src/deprecated.dart';

class MockClipboard {
  Object _clipboardData = <String, dynamic>{
    'text': null,
  };

  Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Clipboard.getData':
        return _clipboardData;
      case 'Clipboard.setData':
        _clipboardData = methodCall.arguments;
        break;
    }
  }
}

void mockClipboard() {
  SystemChannels.platform
      .setMockMethodCallHandler(MockClipboard().handleMethodCall);
}
