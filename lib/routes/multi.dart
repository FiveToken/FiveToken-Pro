import 'package:fil/index.dart';

List<GetPage> getMultiRoutes() {
  var list = <GetPage>[];
  var main = GetPage(name: multiMainPage, page: () => MultiMainPage());
  var import = GetPage(name: multiImportPage, page: () => MultiImportPage());
  var create = GetPage(name: multiCreatePage, page: () => MultiCreatePage());
  var detail = GetPage(name: multiDetailPage, page: () => MultiDetailPage());
  var proposal = GetPage(name: multiProposalPage, page: () => MultiProposalPage());
  var proposalDetail =
      GetPage(name: multiProposalDetailPage, page: () => MultiProposalDetailPage());
  list
    ..add(main)
    ..add(import)
    ..add(create)
    ..add(detail)
    ..add(proposal)
    ..add(proposalDetail);
  return list;
}
