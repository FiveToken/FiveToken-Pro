import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';

class PassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool autofocus;
  PassField(
      {this.controller,
      this.label = '',
      this.hintText = '',
      this.autofocus = true});
  @override
  State<StatefulWidget> createState() {
    return PassFieldState();
  }
}

class PassFieldState extends State<PassField> {
  bool passShow = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          child: Column(
            children: [
              CommonText(
                widget.label,
                size: 13,
                weight: FontWeight.w500,
              ),
              SizedBox(
                height: 13,
              ),
            ],
          ),
          visible: widget.label != '',
        ),
        Container(
          height: 40,
          padding: EdgeInsets.only(left: 15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp("[^\u4e00-\u9fa5]"),
                  ),
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  LengthLimitingTextInputFormatter(20)
                ],
                autofocus: widget.autofocus,
                style: TextStyle(fontSize: 16),
                obscureText: !passShow,
                controller: widget.controller,
                textInputAction: TextInputAction.done,
                decoration:
                    InputDecoration.collapsed(hintText: widget.hintText),
              )),
              IconButton(
                icon: Image(
                    width: 22,
                    image: AssetImage(!passShow
                        ? 'images/close-eye-d.png'
                        : 'images/open-d.png')),
                onPressed: () {
                  setState(() {
                    passShow = !passShow;
                  });
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
