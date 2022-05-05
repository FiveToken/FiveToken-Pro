import 'package:fil/pages/address/add.dart';
import 'package:fil/pages/address/main.dart';
import 'package:fil/pages/address/select.dart';
import 'package:fil/pages/address/wallet.dart';
import 'package:fil/pages/create/entrance.dart';
import 'package:fil/pages/create/importMne.dart';
import 'package:fil/pages/create/importPrivateKey.dart';
import 'package:fil/pages/create/miner.dart';
import 'package:fil/pages/create/mne.dart';
import 'package:fil/pages/create/mneCheck.dart';
import 'package:fil/pages/create/readonly.dart';
import 'package:fil/pages/create/warn.dart';
import 'package:fil/pages/init/lang.dart';
import 'package:fil/pages/init/mode.dart';
import 'package:fil/pages/init/wallet.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/pages/message/body.dart';
import 'package:fil/pages/message/confirm.dart';
import 'package:fil/pages/message/deposit.dart';
import 'package:fil/pages/message/gas.dart';
import 'package:fil/pages/message/make.dart';
import 'package:fil/pages/message/method.dart';
import 'package:fil/pages/message/push.dart';
import 'package:fil/pages/multi/create.dart';
import 'package:fil/pages/multi/detail.dart';
import 'package:fil/pages/multi/import.dart';
import 'package:fil/pages/multi/main.dart';
import 'package:fil/pages/multi/proposal.dart';
import 'package:fil/pages/multi/proposalDetail.dart';
import 'package:fil/pages/other/about.dart';
import 'package:fil/pages/other/discovery.dart';
import 'package:fil/pages/other/lang.dart';
import 'package:fil/pages/other/notification.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/pages/other/setting.dart';
import 'package:fil/pages/other/webview.dart';
import 'package:fil/pages/pass/init.dart';
import 'package:fil/pages/pass/reset.dart';
import 'package:fil/pages/sign/sign.dart';
import 'package:fil/pages/transfer/detail.dart';
import 'package:fil/pages/transfer/transfer.dart';
import 'package:fil/pages/wallet/code.dart';
import 'package:fil/pages/wallet/list.dart';
import 'package:fil/pages/wallet/manage.dart';
import 'package:fil/pages/wallet/mne.dart';
import 'package:fil/pages/wallet/private.dart';
import 'package:fil/routes/routes.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

final routes = [
  // main
  GetPage(name: PublicPath.mainPage, page: () => MainPage()),
  // init
  GetPage(
      name: PublicPath.initLangPage,
      page: () => SelectLangPage(),
      transition: Transition.fadeIn),
  GetPage(name: PublicPath.initWalletPage, page: () => WalletInitPage()),
  GetPage(name: PublicPath.initModePage, page: () => WalletModePage()),
  // create
  GetPage(name: PublicPath.mnePage, page: () => MneCreatePage()),
  GetPage(name: PublicPath.mneCheckPage, page: () => MneCheckPage()),
  GetPage(
      name: PublicPath.importPrivateKeyPage,
      page: () => ImportPrivateKeyPage()),
  GetPage(name: PublicPath.importMnePage, page: () => ImportMnePage()),
  GetPage(name: PublicPath.readonlyPage, page: () => ReadonlyPage()),
  GetPage(name: PublicPath.minerPage, page: () => MinerPage()),
  GetPage(name: PublicPath.createWarnPage, page: () => CreateWarnPage()),
  GetPage(
      name: PublicPath.createEntrancePage, page: () => CreateEntrancePage()),
  // other
  GetPage(name: PublicPath.scanPage, page: () => ScanPage()),
  GetPage(name: PublicPath.setPage, page: () => SetPage()),
  GetPage(name: PublicPath.langPage, page: () => LangPage()),
  GetPage(name: PublicPath.discoveryPage, page: () => DiscoveryPage()),
  GetPage(name: PublicPath.notificationPage, page: () => NotificationPage()),
  GetPage(
      name: PublicPath.webviewPage,
      page: () => WebviewPage(),
      fullscreenDialog: true,
      transition: Transition.downToUp),
  // pass
  GetPage(name: PublicPath.passwordSetPage, page: () => PassInitPage()),
  GetPage(name: PublicPath.passwordResetPage, page: () => PassResetPage()),
  // transfer
  GetPage(name: PublicPath.filTransferPage, page: () => FilTransferNewPage()),
  GetPage(name: PublicPath.filDetailPage, page: () => FilDetailPage()),
  // message
  GetPage(name: PublicPath.mesMakePage, page: () => MesMakePage()),
  GetPage(name: PublicPath.mesPushPage, page: () => MesPushPage()),
  GetPage(name: PublicPath.mesBodyPage, page: () => MesBodyPage()),
  GetPage(name: PublicPath.mesDepositPage, page: () => DepositPage()),
  GetPage(name: PublicPath.mesMethodPage, page: () => MethodSelectPage()),
  GetPage(name: PublicPath.mesConfirmPage, page: () => MessageConfirmPage()),
  GetPage(name: PublicPath.mesGasPage, page: () => MessageGasPage()),
  // multi
  GetPage(name: PublicPath.multiMainPage, page: () => MultiMainPage()),
  GetPage(name: PublicPath.multiImportPage, page: () => MultiImportPage()),
  GetPage(name: PublicPath.multiCreatePage, page: () => MultiCreatePage()),
  GetPage(name: PublicPath.multiDetailPage, page: () => MultiDetailPage()),
  GetPage(name: PublicPath.multiProposalPage, page: () => MultiProposalPage()),
  GetPage(
      name: PublicPath.multiProposalDetailPage,
      page: () => MultiProposalDetailPage()),
  //wallet
  GetPage(name: PublicPath.walletMangePage, page: () => WalletManagePage()),
  GetPage(name: PublicPath.walletMnePage, page: () => WalletMnePage()),
  GetPage(
      name: PublicPath.walletPrivatekey, page: () => WalletPrivatekeyPage()),
  GetPage(name: PublicPath.walletCodePage, page: () => WalletCodePage()),
  GetPage(name: PublicPath.walletSelectPage, page: () => WalletListPage()),
  //address
  GetPage(
      name: PublicPath.addressIndexPage, page: () => AddressBookIndexPage()),
  GetPage(name: PublicPath.addressAddPage, page: () => AddressBookAddPage()),
  GetPage(
      name: PublicPath.addressSelectPage, page: () => AddressBookSelectPage()),
  GetPage(
      name: PublicPath.addressWalletPage,
      page: () => AddressBookWalletSelect()),
  //sign
  GetPage(name: PublicPath.signIndexPage, page: () => SignIndexPage()),
  // setting about
  GetPage(name: PublicPath.aboutPage, page: () => AboutPage())
];
