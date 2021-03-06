import 'package:fil/index.dart';

class Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType type;
  final Widget extra;
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction inputAction;
  final bool enabled;
  final bool autofocus;
  final Widget append;
  final String hintText;
  final FocusNode focusNode;
  final SingleStringParamFn onChanged;
  Field(
      {this.label = '',
      this.controller,
      this.type = TextInputType.text,
      this.extra,
      this.inputAction,
      this.enabled = true,
      this.autofocus = false,
      this.append,
      this.hintText = '',
      this.focusNode,
      this.onChanged,
      this.inputFormatters = const []});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                    visible: label != '',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          label,
                          size: 14,
                          weight: FontWeight.w500,
                        ),
                        append ?? SizedBox()
                      ],
                    )),
                SizedBox(
                  height: label != '' ? 13 : 0,
                ),
                Container(
                  // height: 45,
                  constraints: BoxConstraints(minHeight: 45),
                  padding: EdgeInsets.fromLTRB(15, 12, 0, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: TextField(
                        autofocus: autofocus,
                        enabled: enabled,
                        focusNode: focusNode,
                        onChanged: onChanged,
                        controller: controller,
                        keyboardType: type ?? TextInputType.multiline,
                        maxLines: null,
                        inputFormatters: inputFormatters,
                        textInputAction: inputAction ?? TextInputAction.done,
                        decoration: InputDecoration.collapsed(
                            hintText: hintText,
                            hintStyle: TextStyle(fontSize: 13)),
                      )),
                      extra ??
                          Container(
                            padding: EdgeInsets.only(right: 15),
                          )
                    ],
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white),
                )
              ],
            )),
      ],
    );
  }
}
