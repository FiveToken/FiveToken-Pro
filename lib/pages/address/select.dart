import 'package:fil/index.dart';
/// select a address when transfer 
class AddressBookSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookSelectPageState();
  }
}

class AddressBookSelectPageState extends State<AddressBookSelectPage> {
  var box = OpenedBox.addressBookInsance;
  List<Wallet> list = [];
  void setList() {
    setState(() {
      list = box.values.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    setList();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        title: 'selectAddr'.tr,
        hasFooter: false,
        grey: false,
        actions: [
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.add_circle_outline, color: Colors.black),
            ),
            onTap: () {
              Get.toNamed(addressAddPage).then((value) {
                setList();
              });
            },
          )
        ],
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(addressWalletPage).then((value) {
                    if (value != null && value is Wallet) {
                      Get.back(result: value);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: CustomRadius.b8,
                    color: CustomColor.primary,
                  ),
                  child: Layout.rowBetween([
                    CommonText.white('inAccount'.tr,size: 15),
                    Image(width: 18, image: AssetImage('images/right-w.png'))
                  ]),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Column(
                children: List.generate(
                  list.length,
                  (index) {
                    var wallet = list[index];
                    return Column(
                      children: [
                        GestureDetector(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText.white(wallet.label, size: 15),
                                SizedBox(
                                  height: 5,
                                ),
                                CommonText.white(
                                  dotString(str: wallet.address),
                                  size: 10,
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              borderRadius: CustomRadius.b8,
                              color: CustomColor.primary,
                            ),
                          ),
                          onTap: () {
                            Get.back(result: wallet);
                          },
                        ),
                        SizedBox(
                          height: 8,
                        )
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
