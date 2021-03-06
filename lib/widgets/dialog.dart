import 'package:fil/index.dart';

typedef SingleStringParamFn = void Function(String pass);
void showCustomDialog(BuildContext context, Widget child,
    {Color color, bool dismissible = false}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          child: Material(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: CustomRadius.b8,
                      color: color ?? Colors.white),
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: child,
                )
              ],
            ),
          ),
          onTap: () {
            if (dismissible) {
              Get.back();
            }
          },
        );
      });
}

class CommonTitle extends StatelessWidget {
  final String title;
  final bool showDelete;
  CommonTitle(this.title, {this.showDelete = false});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            child: Container(
          height: 35,
          alignment: Alignment.center,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8), topLeft: Radius.circular(8)),
              color: CustomColor.primary),
          child: CommonText(
            title,
            size: 14,
            color: Colors.white,
            weight: FontWeight.w500,
          ),
        )),
        Positioned(
            right: 18,
            top: 7,
            child: Visibility(
              child: GestureDetector(
                child: Image(
                  width: 20,
                  image: AssetImage('images/close.png'),
                ),
                onTap: () {
                  Get.back();
                },
              ),
              visible: showDelete,
            ))
      ],
    );
  }
}

class PassDialog extends StatefulWidget {
  final SingleStringParamFn callback;
  final Wallet from;
  PassDialog(this.callback, {this.from});
  @override
  State<StatefulWidget> createState() {
    return PassDialogState();
  }
}

class PassDialogState extends State<PassDialog> {
  final TextEditingController controller = TextEditingController();
  void handleConfirm() async {
    var pass = controller.text.trim();
    if (pass == "") {
      showCustomError('enterPass'.tr);
      return;
    }
    var wal = widget.from ?? $store.wal;

    try {
      var valid = await validatePrivateKey(
          wal.addrWithNet, pass, wal.skKek, wal.digest);
      var instance = Global.store;
      var pre = instance.getInt('passWrongCount') ?? 0;
      if (!valid) {
        var now = pre + 1;
        instance.setInt('passWrongCount', pre + 1);
        if (now >= 5) {
          showCustomError('wrongPass'.tr);
          return;
        } else {
          showCustomError('wrongPass'.tr);
          return;
        }
      } else {
        instance.setInt('passWrongCount', 0);
        widget.callback(pass);
        Get.back();
      }
    } catch (e) {
      Get.back();
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        child: Column(
          children: [
            CommonTitle(
              'passCheck'.tr,
              showDelete: true,
            ),
            Padding(
              child: PassField(
                autofocus: true,
                controller: controller,
                label: '',
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            ),
            Divider(
              height: 1,
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: CommonText(
                        'cancel'.tr,
                      ),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      Get.back();
                    },
                  )),
                  Container(
                    width: .2,
                    color: CustomColor.grey,
                  ),
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: CommonText(
                        'sure'.tr,
                        color: CustomColor.primary,
                      ),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      handleConfirm();
                    },
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showPassDialog(BuildContext context, SingleStringParamFn callback,
    {Wallet from}) {
  showCustomDialog(
      context,
      PassDialog(
        callback,
        from: from,
      ),
      color: CustomColor.bgGrey);
}

void showDeleteDialog(BuildContext context,
    {String title, String content, Noop onDelete}) {
  showCustomDialog(
      context,
      Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child:
                      Image(width: 20, image: AssetImage('images/close-d.png')),
                  onTap: () {
                    Get.back();
                  },
                )
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          ),
          CommonText(
            title,
            size: 14,
            weight: FontWeight.w500,
          ),
          SizedBox(
            height: 14,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: CommonText.center(content),
          ),
          SizedBox(
            height: 32,
          ),
          Divider(
            height: 1,
          ),
          Container(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    child: CommonText(
                      'cancel'.tr,
                    ),
                    alignment: Alignment.center,
                  ),
                  onTap: () {
                    Get.back();
                  },
                )),
                Container(
                  width: .2,
                  color: CustomColor.grey,
                ),
                Expanded(
                    child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    child: CommonText(
                      'delete'.tr,
                      color: CustomColor.red,
                    ),
                    alignment: Alignment.center,
                  ),
                  onTap: () {
                    onDelete();
                    Get.back();
                  },
                )),
              ],
            ),
          )
        ],
      ));
}
