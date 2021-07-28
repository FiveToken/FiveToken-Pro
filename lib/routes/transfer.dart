import 'package:fil/index.dart';

List<GetPage> getTransferRoutes() {
  List<GetPage> list = [];
  var transfer =
      GetPage(name: filTransferPage, page: () => FilTransferNewPage());
  var detail = GetPage(name: filDetailPage, page: () => FilDetailPage());
  var gas = GetPage(name: filGasPage, page: () => FilGasPage());
  list..add(transfer)..add(detail)..add(gas);
  return list;
}
