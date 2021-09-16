import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
class QrImageView extends StatelessWidget {
  final String data;
  final double size;
  QrImageView(this.data, {this.size});
  Widget get child {
    return QrImage(
      data: data,
      size: size ?? Get.width - 120,
      backgroundColor: Colors.white,
      version: QrVersions.auto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCustomDialog(
            context,
            Container(
              child: QrImage(
                data: data,
                size: Get.width - 40,
                backgroundColor: Colors.white,
                version: QrVersions.auto,
              ),
            ),dismissible: true);
      },
      child: child,
    );
  }
}
