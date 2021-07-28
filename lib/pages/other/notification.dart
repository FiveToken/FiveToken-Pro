// import 'package:fil/index.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';
// import 'package:oktoast/oktoast.dart';

// class NotificationPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return NotificationPageState();
//   }
// }

// class NotificationPageState extends State<NotificationPage> {
//   Map<String, bool> map = {};
//   final JPush jpush = new JPush();
//   @override
//   void initState() {
//     super.initState();
//     OpenedBox.addressInsance.values.forEach((e) => {map[e.addr] = false});
//     jpush.applyPushAuthority(
//         new NotificationSettingsIOS(sound: true, alert: true, badge: true));
//   }

//   void handleSwitch(String addr, bool v) async {
//     var handle = v ? registerJpushAddress : deleteJpushAddress;
//     showCustomLoading('Loading');
//     var res = await handle(addr);
//     dismissAllToast();
//     if (res) {
//       showCustomToast('opSucc'.tr);
//     } else {
//       showCustomError('opFail'.tr);
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CommonScaffold(
//       title: 'notification'.tr,
//       hasFooter: false,
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 20
//         ),
//         physics: BouncingScrollPhysics(),
//         child: CommonCard(Column(
//           children: OpenedBox.addressInsance.values
//               .where(
//                   (element) => element.walletType == 0 && element.skKek != '')
//               .map((e) => ListTile(
//                     title: Text(e.label),
//                     trailing: CupertinoSwitch(
//                       activeColor: CustomColor.primary,
//                       onChanged: (v) {
//                         handleSwitch(e.addr, v);
//                       },
//                       value: e.push ?? false,
//                     ),
//                   ))
//               .toList(),
//         )),
//       ),
//     );
//   }
// }
