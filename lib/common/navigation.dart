import 'package:fil/api/update.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/cupertino.dart';

class PushObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    var page = route.settings.name;
    pushAction(page: page, type: 'enter');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    $store.setPushBackPage('');
    print('remove route');
    super.didPop(route, previousRoute);
  }
}
