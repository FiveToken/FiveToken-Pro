import 'dart:math';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/common/global.dart';
import 'package:fil/pages/main/online.dart';
import 'package:fil/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// widget of market price
class MarketPrice extends StatefulWidget {
  final bool atto;
  final String balance;
  MarketPrice({this.atto = true, this.balance});
  @override
  State<StatefulWidget> createState() {
    return MarketPriceState();
  }
}

class MarketPriceState extends State<MarketPrice> {
  double price;

  @override
  void initState() {
    super.initState();
  }

  String marketPrice(double price) {
    try {
      var v = double.parse(widget.balance);
      var atto = !widget.atto ? BigInt.from(v * pow(10, 18)) : BigInt.from(v);
      return getMarketPrice(atto.toString(), price);
    } catch (e) {
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MainBloc()..add(getPriceEvent()),
        child: BlocBuilder<MainBloc, MainState>(builder: (context, state) {
          return CommonText(marketPrice(state.price));
        }));
  }
}
