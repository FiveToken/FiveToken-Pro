import 'package:fil/index.dart';

typedef EditCallback = void Function(TMessage);

class UnsignedMessage extends StatefulWidget {
  final Noop onTap;
  final EditCallback edit;
  final TMessage message;
  UnsignedMessage({this.onTap, this.message, this.edit});
  @override
  State<StatefulWidget> createState() {
    return UnsignedMessageState();
  }
}

class UnsignedMessageState extends State<UnsignedMessage> {
  bool get showDetail {
    return widget.message != null;
  }

  bool advanced = false;
  @override
  void initState() {
    super.initState();
    var mode = Global.store.getInt('signMode') ?? 0;
    if (mode == 1) {
      advanced = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout.colStart([
      CommonText(
        'sign'.tr,
        size: 16,
        weight: FontWeight.w500,
      ),
      Container(
        child: CommonText('useCurSign'.tr),
        padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
      ),
      showDetail
          ? advanced
              ? EditableMessage(
                  message: widget.message,
                  edit: widget.edit,
                  exit: () {
                    Global.store.setInt('signMode', 0);
                    setState(() {
                      advanced = false;
                    });
                  },
                )
              : DisplayMessage(
                  onTap: () {
                    Global.store.setInt('signMode', 1);
                    setState(() {
                      advanced = true;
                    });
                  },
                  message: widget.message,
                )
          : GestureDetector(
              child: CommonCard(Container(
                height: Get.height / 2,
                alignment: Alignment.center,
                child: CommonText(
                  'clickCode'.tr,
                  size: 16,
                ),
              )),
              onTap: widget.onTap,
            ),
    ]);
  }
}

class EditableMessage extends StatefulWidget {
  final TMessage message;
  final Noop update;
  final Noop exit;
  final EditCallback edit;
  EditableMessage({this.message, this.update, this.exit, this.edit});
  @override
  State<StatefulWidget> createState() {
    return EditableMessageState();
  }
}

class EditableMessageState extends State<EditableMessage> {
  TextEditingController controller = TextEditingController();
  TextEditingController capCtrl = TextEditingController();
  TextEditingController limitCtrl = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode capNode = FocusNode();
  FocusNode limitNode = FocusNode();
  @override
  void initState() {
    super.initState();
    var mes = widget.message;
    controller.text = mes.nonce.toString();
    capCtrl.text = mes.gasFeeCap;
    limitCtrl.text = mes.gasLimit.toString();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        try {
          var nonce = int.parse(controller.text.trim());
          updateNonce(nonce, syncCtrl: false);
        } catch (e) {}
      }
    });
    capNode.addListener(() {
      if (!capNode.hasFocus) {
        try {
          var mes = TMessage.fromJson(widget.message.toJson());
          var cap = capCtrl.text.trim();
          mes.gasFeeCap = cap;
          if(cap!=''){
            widget.edit(mes);
          }
        } catch (e) {}
      }
    });
    limitNode.addListener(() {
      if (!limitNode.hasFocus) {
        try {
          var mes = TMessage.fromJson(widget.message.toJson());
          var limit = limitCtrl.text.trim();
          mes.gasLimit = num.parse(limit);
          if(limit!=''){
            widget.edit(mes);
          }
        } catch (e) {}
      }
    });
  }

  void updateNonce(num nonce, {bool syncCtrl = true}) {
    if (nonce < 0) {
      return;
    }
    var mes = TMessage.fromJson(widget.message.toJson());
    mes.nonce = nonce;
    widget.edit(mes);
    if (syncCtrl) {
      controller.text = nonce.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout.colStart([
      CommonCard(Container(
        height: 300,
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: CommonText(JsonEncoder.withIndent(' ')
              .convert(widget.message.toLotusMessage())),
        ),
      )),
      SizedBox(
        height: 12,
      ),
      Row(
        children: [
          CommonText('Nonce'),
          SizedBox(
            width: 12,
          ),
          FButton(
            height: 30,
            image: IconButton(
                icon: IconMinus,
                onPressed: () {
                  var nonce = widget.message.nonce - 1;
                  updateNonce(nonce);
                }),
            color: Colors.white,
            onPressed: () {},
          ),
          Container(
            width: 100,
            height: 30,
            color: Colors.white,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 12),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: controller,
              decoration: InputDecoration.collapsed(
                hintText: '',
              ),
            ),
          ),
          FButton(
            height: 30,
            image: IconButton(
                icon: IconPlus,
                onPressed: () {
                  var nonce = widget.message.nonce + 1;
                  updateNonce(nonce);
                }),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      SizedBox(
        height: 12,
      ),
      Field(
        label: 'GasFeeCap',
        controller: capCtrl,
        focusNode: capNode,
        type: TextInputType.number,
        inputFormatters: [PrecisionLimitFormatter(8)],
      ),
      Field(
        label: 'GasLimit',
        controller: limitCtrl,
        focusNode: limitNode,
        type: TextInputType.number,
        inputFormatters: [PrecisionLimitFormatter(8)],
      ),
      Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(const Radius.circular(8)),
          color: CustomColor.primary,
        ),
        margin: EdgeInsets.symmetric(vertical: 20),
        child: FlatButton(
          child: Text(
            'exitAdvance'.tr,
            style: TextStyle(color: Colors.white),
          ),
          onPressed: widget.exit,
          //color: Colors.blue,
        ),
      )
    ]);
  }
}
