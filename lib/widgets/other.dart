import 'package:fil/index.dart';

class ScanAction extends StatelessWidget {
  final Noop handleScan;
  ScanAction({@required this.handleScan});
  @override
  Widget build(BuildContext context) {
    return Padding(
      child: GestureDetector(
          onTap: handleScan,
          child: Image(
            width: 20,
            image: AssetImage('images/scan.png'),
          )),
      padding: EdgeInsets.only(right: 10),
    );
  }
}
