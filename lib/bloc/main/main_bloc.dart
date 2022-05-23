import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/miner.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:meta/meta.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.idle()) {
    on<getPriceEvent>((event, emit) async {
      double price = await Global.provider.getFilPrice();
      Global.price = price;
      emit(state.copyWithMainState(price: price));
    });

    on<setSelectTypeEvent>((event, emit) async {
      emit(state.copyWithMainState(selectType: event.selectType));
    });

    on<getMinerRelatedListEvent>((event, emit) async {
      List<MinerAddress> nodeList;
      try {
        String address = event.address;
        var box = OpenedBox.minerAddressInstance;
        nodeList = await Global.provider.getMinerRelatedAddressBalance(address);
        Map<String, String> labelMap = {};
        box.values.where((element) => element.miner == address).forEach((e) {
          labelMap[e.address + e.type] = e.label;
        });
        await box.deleteAll(labelMap.keys);
        for (var i = 0; i < nodeList.length; i++) {
          var addr = nodeList[i];
          var key = addr.address + addr.type;
          if (labelMap.containsKey(key)) {
            var label = labelMap[key];
            addr.label = label;
          } else {
            addr.label = addr.type;
          }
          box.put(key, addr);
        }
        var list = box.values.where((m) => m.miner == address).toList();
        var ownerIndex = list.indexWhere((element) => element.type == 'owner');
        if (ownerIndex >= 0) {
          var owner = list.removeAt(ownerIndex);
          list.add(owner);
        }
        emit(state.copyWithMainState(nodeList: list));
      } catch (e) {
        print(e);
      }
    });

    on<getPowerInfoEvent>((event, emit) async {
      var res = await Global.provider.getMinerMeta(event.address);
      emit(state.copyWithMainState(meta: res));
    });

    on<getWalletSortedMessagesEvent>((event, emit) async {
      List<StoreMessage> list = getWalletSortedMessages();
      emit(
          state.copyWithMainState(
            messageList: list,
          )
      );
    });

    on<updateEnablePullUpEvent>((event, emit) async {
      emit(
          state.copyWithMainState(
            enablePullUp: event.enablePullUp,
          )
      );
    });


    on<updateBalanceEvent>((event, emit) async {
      var walllet = $store.wal;
      var balance = await Global.provider.getBalance(event.address);
      if (balance != walllet.balance) {
        $store.changeWalletBalance(balance);
        OpenedBox.addressInsance.put(walllet.address, walllet);
      }
      emit(state.copyWithMainState(balance: balance));
    });

    on<updateTransferTypeEvent>((event, emit) async {
      emit(state.copyWithMainState(transferType: event.transferType));
    });

    on<getLatestMessageEvent>((event, emit) async {
      var resList = await getMessages(direction: event.direction);
      List<StoreMessage> messageList;
      bool enablePullUp;
      String mid = '';
      if (resList.isNotEmpty) {
        messageList= getWalletSortedMessages();
        var completeList = messageList.where((mes) => mes.mid != '').toList();
        mid = completeList.last.mid;
        enablePullUp = resList.length >= 20;
      }else{
        enablePullUp = false;
      }
      emit(
          state.copyWithMainState(
              messageList: messageList,
              enablePullUp:enablePullUp,
              mid:mid
          )
      );
    });

    on<getMessagesBeforeLastCompletedMessageEvent>((event, emit) async {
      var list = await getMessages(direction: event.direction, mid: event.mid);
      List<StoreMessage> messageList;
      bool enablePullUp;
      String mid = '';
      if (list.isNotEmpty) {
        messageList = getWalletSortedMessages();
        var completeList = messageList.where((mes) => mes.mid != '').toList();
        mid = completeList.last.mid;
        enablePullUp = list.length >= 20;
      } else {
        enablePullUp = false;
      }
      emit(
          state.copyWithMainState(
              messageList: messageList,
              enablePullUp:enablePullUp,
              mid:mid
          )
      );
    });


    on<getMinerBalanceInfoEvent>((event, emit) async {
      String address = event.address;
      var result = await Global.provider.getMinerBalanceInfo(address);
      OpenedBox.minerBalanceInstance.put(address, result);
      emit(state.copyWithMainState(info: result));
    });

    on<getMinerYesterdayInfoEvent>((event, emit) async {
      String address = event.address;
      var box = OpenedBox.minerStatisticInstance;
      ;
      MinerHistoricalStats res =
          await Global.provider.getMinerYesterdayInfo(address);
      box.put(address, res);
      emit(state.copyWithMainState(stats: res));
    });
  }
}

List<StoreMessage> getWalletSortedMessages() {
  var mesBox = OpenedBox.messageInsance;
  var list = <StoreMessage>[];
  var resList = <StoreMessage>[];
  var address = $store.wal.address;
  list = mesBox.values.where((message) => message.from == address || message.to == address).toList();
  var pendingList = <StoreMessage>[];
  var completeList = <StoreMessage>[];
  list.forEach((mes) {
    if (mes.pending == 0) {
      completeList.add(mes);
    } else {
      pendingList.add(mes);
    }
  });
  pendingList.sort((a, b) {
    if (a.blockTime != null && b.blockTime != null) {
      return b.blockTime.compareTo(a.blockTime);
    } else {
      return 1;
    }
  });
  completeList.sort((a, b) {
    if (a.blockTime != null && b.blockTime != null) {
      return b.blockTime.compareTo(a.blockTime);
    } else {
      return 1;
    }
  });
  resList..addAll(pendingList)..addAll(completeList);
  return resList;
}

Future<List<StoreMessage>> getMessages({String direction = 'up', String mid = ''}) async {
  try {
    var list = await Global.provider
        .getMessageList(actor: $store.addr, mid: mid, direction: direction);
    if (list.isNotEmpty) {
      var maxNonce = 0;
      var messages = list.map((e) {
        var mes = StoreMessage.fromJson(e);
        mes.pending = 0;
        mes.owner = $store.addr;
        if (mes.from == $store.wal.addressWithNet &&
            mes.nonce != null &&
            maxNonce < mes.nonce) {
          maxNonce = mes.nonce.toInt();
        }
        return mes;
      }).toList();

      /// if the current nonce of the wallet is biggger than the nonce of the message,
      /// message was either packaged or discarded
      /// delete it from local db
      var mesBox = OpenedBox.messageInsance;
      var address = $store.wal.address;
      List<StoreMessage> messageList = mesBox.values.where((message) => message.from == address || message.to == address).toList();
      var pendingList = messageList.where((mes) => mes.pending == 1).toList();
      if (pendingList.isNotEmpty) {
        for (var k = 0; k < pendingList.length; k++) {
          var mes = pendingList[k];
          if (mes.nonce <= maxNonce && mes.owner == $store.addr) {
            await OpenedBox.pushInsance.delete(mes.signedCid);
            await mesBox.delete(mes.signedCid);
          }
        }
      }
      if (direction == 'down') {
        var completeKeys = messageList
            .where((mes) => mes.pending == 0)
            .map((mes) => mes.signedCid);
        await mesBox.deleteAll(completeKeys);
      }
      for (var i = 0; i < messages.length; i++) {
        var m = messages[i];
        if (FilecoinMethod.validMethods.contains(m.methodName)) {
          await mesBox.put(m.signedCid, m);
        }
      }

      /// if there is a pending message which send for create multi-sig wallet,
      /// get the detail info of the multi-sig wallet from this message
      if (messages.where((mes) => mes.to == FilecoinAccount.f01).isNotEmpty &&
          direction == 'down') {
        checkCreateMessages();
      }
      return messages.toList();
    } else {
      return [];
    }
  } catch (e) {
    print(e);
    return [];
  }
}

Future checkCreateMessages() async {
  var box = OpenedBox.multiInsance;
  var l = box.values.where((wal) => wal.status == 0).toList();
  if (l.isNotEmpty) {
    for (var i = 0; i < l.length; i++) {
      var wal = l[i];

      try {
        var detail = await Global.provider.getMessageDetail(wal.cid);
        var code = detail.exitCode;
        var copy = MultiSignWallet(
            cid: wal.cid,
            signers: wal.signers,
            label: wal.label,
            blockTime: detail.blockTime,
            threshold: wal.threshold);
        if (code == 0 || code == null) {
          copy.status = 1;
          var returns = detail.returns;
          if (returns != null && returns['IDAddress'] != null) {
            try {
              var res =
              await Global.provider.getMultiInfo(returns['IDAddress'] as String);
              if (res.signerMap != null && res.signerMap.keys.isNotEmpty) {
                box.delete(wal.cid);
                copy.id = returns['IDAddress'] as String;
                copy.signerMap = res.signerMap;
                copy.robustAddress = res.robustAddress;
                box.put(returns['IDAddress'], copy);
              }
            } catch (e) {
              print(e);
            }
          }
        } else {
          wal.status = -1;
          box.put(wal.cid, wal);
        }
      } catch (e) {
        var time = wal.blockTime;
        var now = getSecondSinceEpoch();
        if (now - time > 3600 * 2) {
          wal.status = -1;
          box.put(wal.cid, wal);
        }
      }
    }
  }
}