import 'package:fil/bloc/method/method_bloc.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/common/formatter.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/noop.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// select a method
class MethodMap {
  static Map<String, String> get _methodMap => {
        '0': 'transfer'.tr,
        '2': 'createMiner'.tr,
        '3': 'changeWorker'.tr,
        '16': 'withdraw'.tr,
        '21': 'confirmUpdateWorkerKey'.tr,
        '23': 'changeOwner'.tr
      };
  String getMethodDes(String method, {String to}) {
    var des = _methodMap[method];
    if (to != null) {
      if (method == '2') {
        if (to == FilecoinAccount.f01) {
          des = FilecoinMethod.exec;
        } else if (to == FilecoinAccount.f04) {
          des = 'createMiner'.tr;
        } else {
          des = 'propose'.tr;
        }
      }
      if (method == '3') {
        if (OpenedBox.multiInsance.containsKey(to)) {
          des = 'approve'.tr;
        } else {
          des = 'changeWorker'.tr;
        }
      }
    }
    return "${'method'.tr} $method${des != null ? ':$des' : ''}";
  }

  static String getMethodNameByNum(String method) {
    return _methodMap.containsKey(method) ? _methodMap[method] : method;
  }
}

/// page of method select
class MethodSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MethodSelectPageState();
  }
}

class MethodSelectPageState extends State<MethodSelectPage> {
  bool hideMethods = false;
  TextEditingController controller = TextEditingController();
  void changeMethod(BuildContext context, String method) {
    BlocProvider.of<MethodBloc>(context)
      ..add(SetMethodEvent(method))
      ..add(SetCustomEvent(false));
  }

  List<String> get _methods {
    return [
      '0',
      '16',
      '23',
      '3',
      '21',
      '2',
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var filterList =
        _methods.where((m) => hideMethods ? m != '2' : true).toList();
    return BlocProvider(
        create: (context) => MethodBloc()..add(initMethodEvent()),
        child: BlocBuilder<MethodBloc, MethodState>(builder: (context, state) {
          return CommonScaffold(
            title: 'advanced'.tr,
            footerText: 'sure'.tr,
            onPressed: () {
              Get.back(result: state.method);
            },
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(12, 20, 12, 100),
              child: Layout.colStart([
                CommonText.main('opOption'.tr),
                SizedBox(
                  height: 13,
                ),
                Column(
                  children: List.generate(filterList.length, (index) {
                    var met = filterList[index];
                    return MethodSelectItem(
                        method: met,
                        active: state.method == met,
                        onTap: () {
                          changeMethod(context, met);
                        });
                  }),
                ),
                Visibility(
                    visible: false,
                    child: GestureDetector(
                      onTap: () {
                        BlocProvider.of<MethodBloc>(context)
                          ..add(SetMethodEvent(''))
                          ..add(SetCustomEvent(true));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: CustomRadius.b6,
                            color: state.custom
                                ? CustomColor.primary
                                : Colors.white),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        child: Layout.colStart([
                          Layout.rowStart([
                            Icon(
                              Icons.check_circle_outline,
                              color: state.custom
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CommonText(
                              'custom'.tr,
                              color: state.custom ? Colors.white : Colors.black,
                            )
                          ]),
                          Visibility(
                              visible: state.custom,
                              child: Layout.colStart([
                                Divider(
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                CommonText(
                                  '${'method'.tr}ID',
                                  color: state.custom
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                Field(
                                  inputAction: TextInputAction.done,
                                  controller: controller,
                                  inputFormatters: [PrecisionLimitFormatter(8)],
                                )
                              ]))
                        ]),
                      ),
                    ))
              ]),
            ),
          );
        }));
  }
}

class MethodSelectItem extends StatelessWidget {
  final String method;
  final bool active;
  final Noop onTap;
  final bool custom;
  final bool hasIcon;
  MethodSelectItem(
      {@required this.method,
      @required this.active,
      @required this.onTap,
      this.hasIcon = true,
      this.custom = false});
  bool get caculateActive {
    return !custom && active;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
            borderRadius: CustomRadius.b6,
            color: caculateActive ? CustomColor.primary : Colors.white),
        child: Row(
          children: [
            Visibility(
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: caculateActive ? Colors.white : Colors.transparent,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              visible: hasIcon,
            ),
            CommonText(
              MethodMap.getMethodNameByNum(method),
              color: caculateActive ? Colors.white : Colors.black,
            ),
            Spacer(),
            CommonText(
              'ID: $method',
              color: caculateActive ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

void showMethodSelector(
    {@required BuildContext context,
    @required List<String> methods,
    @required ValueChanged<String> onTap,
    @required String title}) {
  showCustomModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              CommonTitle(
                title,
                showDelete: true,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Column(
                  children: methods
                      .map((method) => MethodSelectItem(
                          method: method,
                          hasIcon: false,
                          active: false,
                          onTap: () {
                            Get.back();
                            onTap(method);
                          }))
                      .toList(),
                ),
              )
            ],
          ),
        );
      });
}
