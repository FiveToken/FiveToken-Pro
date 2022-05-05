import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/common/global.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';

part 'multi_event.dart';
part 'multi_state.dart';

class MultiBloc extends Bloc<MultiEvent, MultiState> {
  MultiBloc() : super(MultiState.idle()) {
    on<getMultiInfoEvent>((event, emit) async {
      var info = await Global.provider.getMultiInfo(event.id);
      if ($store.multiWal.balance != info.balance) {
        var box = OpenedBox.multiInsance;
        $store.multiWal.balance = info.balance;
        box.put($store.multiWal.id, $store.multiWal);
        $store.changeMultiWalletBalance($store.multiWal.balance);
        emit(state.copyWithMultiState(balance: info.balance));
      }
    });

    on<updateSelectTypeEvent>((event, emit) {
      emit(state.copyWithMultiState(selectType: event.selectType));
    });

    on<getWalletSortedMessagesEvent>((event, emit) async {
      int selectType = event.selectType;
      List<CacheMultiMessage> list = getWalletSortedMessages(selectType: selectType);
      emit(state.copyWithMultiState(messageList: list));
    });

    on<getLatestMessagesEvent>((event, emit) async {
      var resList = await getMessages(
        direction: 'down', selectType:event.selectType
      );
      List<CacheMultiMessage> messageList = [];
      bool enablePullUp = false;
      String mid='';
      if (resList.isNotEmpty) {
        messageList = getWalletSortedMessages(selectType:event.selectType);
        var completeList = messageList.where((mes) => mes.mid != '').toList();
        mid = completeList.last.mid;
        enablePullUp = resList.length >= 20;
      }
      emit(
          state.copyWithMultiState(
            messageList: messageList,
              enablePullUp: enablePullUp,
              mid:mid
          )
      );
    });

    on<getMessagesBeforeLastCompletedMessageEvent>((event, emit) async {
      List<CacheMultiMessage> list = await getMessages(
        selectType: event.selectType,
        mid: event.mid,
        direction: event.direction,
      );
      List<CacheMultiMessage> messageList = [];
      bool enablePullUp;
      String mid = '';
      if (list.isNotEmpty) {
        messageList = getWalletSortedMessages(selectType:event.selectType);
        var completeList = messageList.where((mes) => mes.mid != '').toList();
        mid = completeList.last.mid;
        enablePullUp = list.length >= 20;
      } else {
        enablePullUp = false;
      }
      emit(state.copyWithMultiState(
        messageList: messageList,
        enablePullUp: enablePullUp,
        mid: mid
      ));
    });
  }
}

List<CacheMultiMessage> getWalletSortedMessages({ int selectType}) {
  MultiSignWallet wallet = $store.multiWal;
  var mesBox = OpenedBox.multiProposeInstance;
  var list = <CacheMultiMessage>[];
  var resList = <CacheMultiMessage>[];
  var address = wallet.id;
  var robustAddress = wallet.robustAddress;
  list = mesBox.values
      .where((message) =>
          (message.to == address || message.to == robustAddress) &&
          message.type == selectType)
      .toList();
  var pendingList = <CacheMultiMessage>[];
  var completeList = <CacheMultiMessage>[];
  list.forEach((mes) {
    if (mes.pending == 0) {
      completeList.add(mes);
    } else {
      pendingList.add(mes);
    }
  });
  pendingList.sort((a, b) {
    if (a.nonce != null && b.nonce != null) {
      return b.blockTime.compareTo(a.blockTime);
    } else {
      return 1;
    }
  });
  completeList.sort((a, b) {
    if (a.nonce != null && b.nonce != null) {
      return b.blockTime.compareTo(a.blockTime);
    } else {
      return 1;
    }
  });
  resList
    ..addAll(pendingList)
    ..addAll(completeList);
  return resList;
}

Future<List<CacheMultiMessage>> getMessages({String direction = 'up', String mid = '', int selectType}) async {
  try {
    MultiSignWallet wallet = $store.multiWal;
    var mesBox = OpenedBox.multiProposeInstance;
    var handle = selectType == 0
        ? Global.provider.getMultiMessageList
        : Global.provider.getMultiReceiveMessages;
    var list = await handle(actor: wallet.id, direction: direction, mid: mid);
    if (list.isNotEmpty) {
      var maxNonce = 0;
      var messages = list.map((e) {
        var mes = CacheMultiMessage.fromJson(e);
        mes.pending = 0;
        mes.owner = $store.addr;
        mes.type = selectType;
        if (mes.nonce != null &&
            mes.nonce > maxNonce &&
            mes.from == $store.addr) {
          maxNonce = mes.nonce;
        }
        return mes;
      }).toList();
      var address = wallet.id;
      var robustAddress = wallet.robustAddress;
      List<CacheMultiMessage> messageList = mesBox.values
          .where((message) =>
              (message.to == address || message.to == robustAddress) &&
              message.type == selectType)
          .toList();
      var pendingList = messageList.where((mes) => mes.pending == 1).toList();
      if (pendingList.isNotEmpty) {
        for (var k = 0; k < pendingList.length; k++) {
          var mes = pendingList[k];
          if (mes.nonce <= maxNonce && mes.owner == $store.addr) {
            await mesBox.delete(mes.cid);
          }
        }
      }
      if (direction == 'down') {
        var completeKeys =
            messageList.where((mes) => mes.pending == 0).map((mes) => mes.cid);
        await mesBox.deleteAll(completeKeys);
      }
      for (var i = 0; i < messages.length; i++) {
        var m = messages[i];
        var approves = OpenedBox.multiApproveInstance.values
            .where((apr) => apr.proposeCid == m.cid)
            .toList();
        if (m.approves.isNotEmpty && approves.isNotEmpty) {
          List<String> deleteKeys = [];
          m.approves.forEach((apr) {
            var from = apr.from;
            var relatedApproves =
                approves.where((ap) => ap.from == from).toList();
            relatedApproves.forEach((ap) async {
              if (apr.exitCode == 0) {
                deleteKeys.add(ap.cid);
              } else {
                if (apr.nonce != null && ap.nonce != null) {
                  if (apr.nonce >= ap.nonce) {
                    deleteKeys.add(ap.cid);
                  }
                } else {
                  deleteKeys.add(ap.cid);
                }
              }
            });
          });
          if (deleteKeys.isNotEmpty) {
            await OpenedBox.multiApproveInstance.deleteAll(deleteKeys);
          }
        }
        OpenedBox.multiProposeInstance.put(m.cid, m);
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

