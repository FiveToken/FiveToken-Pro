import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:oktoast/oktoast.dart';

/// approve a proposal
class MultiApprovalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MultiApprovalPageState();
  }
}

class MultiApprovalPageState extends State<MultiApprovalPage> {
  TextEditingController controller = TextEditingController();
  int txid;
  String to = '';
  String value = '0';
  int method = 0;
  dynamic params;
  String proposer;
  String actorId = '';
  MultiSignWallet wallet = $store.multiWal;
  var nonceBoxInstance = OpenedBox.nonceInsance;
  Wallet signerWallet = $store.wal;
  MessageDetail detail = MessageDetail();
  Gas chainGas = Gas();
  void handleSearch() async {
    try {
      var id = controller.text.trim();
      showCustomLoading('Loading');
      var detail = await getMessageDetail(StoreMessage(signedCid: id));
      dismissAllToast();
      if (detail.height != null && detail.returns != null) {
        await getActor(detail.from);
        setState(() {
          txid = detail.returns['TxnID'] as int;
          var args = detail.args;
          to = args['To'];
          method = args['Method'];
          params = args['Params'];
          value = args['Value'];
          proposer = detail.from;
          this.detail = detail;
        });
      } else {
        showCustomError('errorCid'.tr);
      }
    } catch (e) {
      dismissAllToast();

      showCustomError('searchProposalFailed'.tr);
    }
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      controller.text = Get.arguments['cid'];
      Future.delayed(Duration.zero).then((value) => handleSearch());
    }
    FilecoinProvider.getNonceAndGas(to: wallet.id, method: 3);
  }

  Future getActor(String addr) async {
    var id = await getAddressActor(addr);
    if (id != '') {
      actorId = id;
    }
  }

  void hanldeConfirm() async {
    if (proposer.substring(1) == signerWallet.address.substring(1)) {
      showCustomError('sameAsSigner'.tr);
      return;
    }
    if (!$store.canPush) {
      var valid =
          await FilecoinProvider.getNonceAndGas(to: wallet.id, method: 2);
      if (!valid) {
        showCustomError('errorSetGas'.tr);
        return;
      }
    }
    var balanceNum = BigInt.tryParse($store.wal.balance);
    var feeNum = $store.gas.value.feeNum;
    if (balanceNum < feeNum) {
      showCustomError('errorLowBalance'.tr);
      return;
    }
    if (actorId == '') {
      if (!wallet.signerMap.containsKey(proposer)) {
        showCustomError('getActorFailed'.tr);
        return;
      } else {
        actorId = wallet.signerMap[proposer];
      }
    }
    if ($store.wal.readonly == 1) {
      var msg = await genMsg();
      $store.setPushBackPage(multiMainPage);
      Get.toNamed(mesBodyPage, arguments: {'mes': msg});
    } else {
      FilecoinProvider.checkSpeedUpOrMakeNew(
          context: context,
          onNew: () {
            showPassDialog(context, (String pass) {
              pushMessage(pass);
            });
          },
          onSpeedup: () {
            showPassDialog(context, (String pass) async {
              var wal = $store.wal;
              var private =
                  await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
              var res = await FilecoinProvider.speedup(
                  private: private, gas: $store.chainGas);
              if (res != '') {
                Get.back();
              }
            });
          });
    }
  }

  String get from {
    return $store.wal.addrWithNet;
  }

  Future<TMessage> genMsg() async {
    var ctrl = $store;
    var transactionInput = {
      'tx_id': txid,
      'requester': actorId,
      'to': to,
      'value': value,
      'method': method,
      'params': params,
    };
    var str = jsonEncode(transactionInput);
    var p = await Flotus.genApprovalV3(str);
    var decodeParams = jsonDecode(p);
    var msg = TMessage(
        version: 0,
        method: 3,
        nonce: $store.nonce,
        from: from,
        to: wallet.id,
        params: decodeParams['param'],
        value: '0',
        gasFeeCap: ctrl.gas.value.feeCap,
        gasLimit: ctrl.gas.value.gasLimit,
        gasPremium: ctrl.gas.value.premium);
    return msg;
  }

  void pushMessage(String pass) async {
    var msg = await genMsg();
    var wal = $store.wal;
    var private = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
    var res = await FilecoinProvider.sendMessage(
        message: msg, private: private, multiId: wallet.id);
    if (res != '') {
      Get.offNamedUntil(
          multiMainPage, (route) => route.settings.name == mainPage);
    }
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.MessageId})
        .then((value) {
      controller.text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var show = to != '';
    return CommonScaffold(
      onPressed: () {
        hanldeConfirm();
      },
      title: 'approve'.tr,
      footerText: 'approve'.tr,
      hasFooter: show,
      actions: [
        Padding(
          child: GestureDetector(
              onTap: handleScan,
              child: Image(
                width: 20,
                image: AssetImage('images/scan.png'),
              )),
          padding: EdgeInsets.only(right: 10),
        )
      ],
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 20, 12, 120),
        child: Layout.colStart([
          Field(
            controller: controller,
            hintText: 'enterPropsalId'.tr,
            label: 'searchProposal'.tr,
            append: GestureDetector(
              child: Image(width: 20, image: AssetImage('images/cop.png')),
              onTap: () async {
                var data = await Clipboard.getData(Clipboard.kTextPlain);
                controller.text = data.text;
              },
            ),
            extra: GestureDetector(
              onTap: () {
                handleSearch();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.search,
                ),
              ),
            ),
          ),
          Visibility(
              visible: txid != null,
              child: Layout.colStart([
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: CommonText.main('proposalInfo'.tr),
                ),
                CommonCard(Column(
                  children: [
                    MessageRow(
                      label: 'amount'.tr,
                      value: atto2Fil(value) + ' FIL',
                    ),
                    MessageRow(
                      label: 'proposer'.tr,
                      value: detail.from,
                    ),
                    MessageRow(
                      label: 'to'.tr,
                      value: to,
                    ),
                    MessageRow(
                      label: 'cid'.tr,
                      value: detail.signedCid,
                    ),
                    MessageRow(
                      label: 'height'.tr,
                      value: detail.height.toString(),
                    ),
                  ],
                )),
                Obx(() => SetGas(
                      maxFee: $store.maxFee,
                      gas: $store.chainGas,
                    )),
              ])),
        ]),
      ),
    );
  }
}
