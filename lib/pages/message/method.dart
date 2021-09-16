import 'package:fil/index.dart';

/// select a method
class MethodMap {
  String getMethodDes(String method, {String to}) {
    var _methodMap = {
      '0': 'transfer'.tr,
      '2': 'createMiner'.tr,
      '3': 'changeWorker'.tr,
      '16': 'withdraw'.tr,
      '21': 'confirmUpdateWorkerKey'.tr,
      '23': 'changeOwner'.tr
    };
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
}

class MethodSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MethodSelectPageState();
  }
}

class MethodSelectPageState extends State<MethodSelectPage> {
  String method;
  bool custom = false;
  bool hideMethods = false;
  TextEditingController controller = TextEditingController();
  void changeMethod(String method) {
    setState(() {
      this.method = method;
      custom = false;
    });
  }

  List<String> get _methods {
    return ['0', '2', '3', '16', '21', '23'];
  }

  @override
  void initState() {
    super.initState();
    var args = Get.arguments;
    if (args != null && args['method'] != null) {
      var method = args['method'];
      this.method = method;
      if (args['hideMethods'] != null && args['hideMethods'] == true) {
        this.hideMethods = true;
      }
      if (!_methods.contains(method)) {
        this.custom = true;
        controller.text = method;
      }
    }
    controller.addListener(() {
      var v = controller.text.trim();
      try {
        int.parse(v);
        this.method = v;
      } catch (e) {
        this.method = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var filterList =
        _methods.where((m) => hideMethods ? m != '2' : true).toList();
    return CommonScaffold(
      title: 'advanced'.tr,
      footerText: 'sure'.tr,
      onPressed: () {
        Get.back(result: method);
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
                  active: method == met,
                  onTap: () {
                    changeMethod(met);
                  });
            }),
          ),
          Visibility(
              visible: false,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    custom = true;
                    method = '';
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: CustomRadius.b6,
                      color: custom ? CustomColor.primary : Colors.white),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  child: Layout.colStart([
                    Layout.rowStart([
                      Icon(
                        Icons.check_circle_outline,
                        color: custom ? Colors.white : Colors.transparent,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CommonText(
                        'custom'.tr,
                        color: custom ? Colors.white : Colors.black,
                      )
                    ]),
                    Visibility(
                        visible: custom,
                        child: Layout.colStart([
                          Divider(
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CommonText(
                            '${'method'.tr}ID',
                            color: custom ? Colors.white : Colors.black,
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
  }
}

class MethodSelectItem extends StatelessWidget {
  final String method;
  final bool active;
  final Noop onTap;
  final bool custom;
  MethodSelectItem(
      {@required this.method,
      @required this.active,
      @required this.onTap,
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
            Icon(
              Icons.check_circle_outline,
              color: caculateActive ? Colors.white : Colors.transparent,
            ),
            SizedBox(
              width: 10,
            ),
            CommonText(
              MethodMap().getMethodDes(method),
              color: caculateActive ? Colors.white : Colors.black,
            )
          ],
        ),
      ),
    );
  }
}

void showMethodSelector(
    {@required BuildContext context,
    @required List<String> methods,
    @required SingleParamCallback<String> onTap,
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
