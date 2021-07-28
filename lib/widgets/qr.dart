import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

class QrCodeImage extends StatelessWidget {
  final String data;
  final GlobalKey _key = GlobalKey();
  QrCodeImage(this.data);
  Future saveImage() async {
    RenderRepaintBoundary boundary = _key.currentContext.findRenderObject();
    var image = await boundary.toImage(pixelRatio: 6.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    var permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission == PermissionStatus.granted) {
      ImageGallerySaver.saveImage(pngBytes).then((result) {
        if (result != "") {
        } else {}
        Get.back();
      }).catchError((err) {
        print(err);
      });
    } else {
      PermissionHandler().requestPermissions(<PermissionGroup>[
        PermissionGroup.storage,
      ]).then((value) {
        saveImage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {},
      child: RepaintBoundary(
        key: _key,
        child: QrImage(
            data: data,
            backgroundColor: Colors.white,
            version: QrVersions.auto,
            size: 200.0,
            embeddedImageStyle: QrEmbeddedImageStyle(size: Size(30, 30)),
            embeddedImage: AssetImage('images/ic_launcher.png')),
      ),
    );
  }
}

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
