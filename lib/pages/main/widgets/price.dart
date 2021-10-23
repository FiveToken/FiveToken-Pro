import 'package:fil/index.dart';
import 'package:fil/pages/main/online.dart';

class MarketPrice extends StatefulWidget {
  final bool atto;
  final String balance;
  MarketPrice({this.atto=true, this.balance});
  @override
  State<StatefulWidget> createState() {
    return MarketPriceState();
  }
}

class MarketPriceState extends State<MarketPrice> {
  FilPrice price;
  void getPrice() async {
    var res = await getFilPrice();
    Global.price = res;
    if (res.cny != 0&&mounted) {
      setState(() {
        this.price = res;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    getPrice();
  }
  String get marketPrice {
    try {
      var v = double.parse(widget.balance);
      var atto = !widget.atto?BigInt.from(v * pow(10, 18)):BigInt.from(v);
      return getMarketPrice(atto.toString(), 7);
    } catch (e) {
      return '--';
    }
  }
  @override
  Widget build(BuildContext context) {
    return CommonText(marketPrice);
  }
}
