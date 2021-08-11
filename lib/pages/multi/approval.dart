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
  MultiSignWallet wallet = singleStoreController.multiWal;
  var nonceBoxInstance = OpenedBox.nonceInsance;
  int nonce;
  Wallet signerWallet = singleStoreController.wal;
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

  Future getGas() async {
    var res = await getGasDetail(to: wallet.id, method: 3);
    if (res.feeCap != '0') {
      singleStoreController.setGas(res);
      setState(() {
        this.chainGas = res;
      });
    }
  }

  void getWalletNonce() async {
    var wal = singleStoreController.wal;
    var nonce = await getNonce(wal);
    var address = wal.address;
    var now = DateTime.now().millisecondsSinceEpoch;
    if (nonce != -1) {
      this.nonce = nonce;
      if (!nonceBoxInstance.containsKey(address)) {
        nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
      } else {
        Nonce nonceInfo = nonceBoxInstance.get(address);
        var interval = 5 * 60 * 1000;
        if (now - nonceInfo.time > interval) {
          nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      controller.text = Get.arguments['cid'];
      Future.delayed(Duration.zero).then((value) => handleSearch());
    }
    getWalletNonce();
    getGas();
    //getActor();
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
    if (singleStoreController.gas.value.feeCap == '0') {
      await getGas();
      if (singleStoreController.gas.value.feeCap == '0') {
        showCustomError('wrongGas'.tr);
        return;
      }
    }
    if (actorId == '') {
      if (!wallet.signerMap.containsKey(proposer)) {
        showCustomError('getActorFailed'.tr);
        return;
      } else {
        actorId = wallet.signerMap[proposer];
      }
    }
    if (nonce == null || nonce == -1) {
      showCustomError("errorGetNonce".tr);
      return;
    }
    if (singleStoreController.wal.readonly == 1) {
      var msg = await genMsg();
      singleStoreController.setPushBackPage(multiMainPage);
      Get.toNamed(mesBodyPage, arguments: {'mes': msg});
    } else {
      showPassDialog(context, (String pass) {
        pushMessage(pass);
      });
    }
  }

  String get from {
    return singleStoreController.wal.addrWithNet;
  }

  int get realNonce {
    var cahcheNonce = nonceBoxInstance.get(from);
    var storeNonce = 0;
    if (cahcheNonce != null) {
      storeNonce = cahcheNonce.value;
    }
    var n = max(nonce, storeNonce);
    return n;
  }

  Future<TMessage> genMsg() async {
    var ctrl = singleStoreController;
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
        nonce: realNonce,
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
    var ctrl = singleStoreController;
    var msg = await genMsg();
    String sign = '';
    num signType;
    var cid = await Flotus.messageCid(msg: jsonEncode(msg));
    var wal = singleStoreController.wal;
    var ck = await getPrivateKey(wal.addrWithNet, pass, wal.skKek);
    //var ck = base64.encode(sk);
    if (ctrl.wal.type == '1') {
      signType = SignTypeSecp;
      sign = await Flotus.secpSign(ck: ck, msg: cid);
    } else {
      signType = SignTypeBls;
      sign = await Bls.cksign(num: "$ck $cid");
    }
    var sm = SignedMessage(msg, Signature(signType, sign));
    String res = await pushSignedMsg(sm.toLotusSignedMessage());
    if (res != '') {
      ctrl.setGas(Gas());
      OpenedBox.multiMesInsance.put(
          res,
          StoreMultiMessage(
              pending: 1,
              from: from,
              to: wallet.id,
              value: '0',
              owner: from,
              signedCid: res,
              msigTo: to,
              msigValue: value,
              type: 'approval',
              proposalCid: controller.text.trim(),
              blockTime: getSecondSinceEpoch()));
      var oldNonce = nonceBoxInstance.get(from);
      nonceBoxInstance.put(
          from, Nonce(value: realNonce + 1, time: oldNonce.time));
    }
    Get.offNamedUntil(
        multiMainPage, (route) => route.settings.name == mainPage);
  }

  String get maxFee {
    var maxFee = formatFil(singleStoreController.gas.value.attoFil);
    return maxFee;
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
                      maxFee:
                          singleStoreController.maxFee,
                      gas: chainGas,
                    )),
              ])),
        ]),
      ),
    );
  }
}
