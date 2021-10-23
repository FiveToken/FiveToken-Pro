import 'package:fil/index.dart';
class CommonCard extends StatelessWidget {
  final Widget child;
  CommonCard(this.child);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
    );
  }
}

class TapCard extends StatelessWidget {
  final List<CardItem> items;
  TapCard({this.items});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(7)),
      child: Column(
        children: List.generate(items.length, (index) {
          return Container(
            child: Column(
              children: [
                items[index],
                Visibility(
                    child: Divider(
                      height: 1,
                    ),
                    visible: index != items.length - 1)
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 15),
          );
        }),
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final String label;
  final Noop onTap;
  final Widget append;
  CardItem({@required this.label, this.onTap, this.append});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [CommonText.main(label), append ?? ImageAr],
        ),
        height: 40,
      ),
      onTap: onTap,
    );
  }
}