import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/constant.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/toast.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:meta/meta.dart';
import 'package:oktoast/oktoast.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc() : super(DetailState.idle()) {
    on<getMessageDetailEvent>((event, emit) async {
      final argumentsMessage = event.message;

      String from;
      String to;
      num nonce;
      num height;
      String value;
      num pending;
      String methodName;
      String allGasFee;
      String signedCid;
      dynamic args;
      dynamic returns;

      if (argumentsMessage.pending == 1 ||
          argumentsMessage.exitCode == -1 ||
          argumentsMessage.exitCode == -2) {
        from = argumentsMessage.from;
        to = argumentsMessage.to;
        value = argumentsMessage.value;
        methodName = '';
        signedCid = argumentsMessage.signedCid;
      } else {
        showCustomLoading('Loading');
        var res =
            await Global.provider.getMessageDetail(argumentsMessage.signedCid);
        dismissAllToast();
        if (res.height != null) {
          if (argumentsMessage.multiMethod == '') {
            from = res.from;
            value = res.value;
            methodName = res.methodName;
            signedCid = res.signedCid;
            height = res.height;
            allGasFee = res.allGasFee;

            nonce = res.nonce;
            to = res.to;
            // if (res.methodName == FilecoinMethod.withdraw && res.args is Map) {
            //   amount = res.args['AmountRequested'] as String;
            // }
          } else {
            from = argumentsMessage.from;
            value = argumentsMessage.value;
            methodName = FilecoinMethod.send;
            signedCid = argumentsMessage.signedCid;
            height = res.height;
            allGasFee = res.allGasFee;
            to = argumentsMessage.to;
          }
        }
      }
      emit(state.copyWithDetailState(
        from: from,
        to: to,
        value: value,
        methodName: methodName,
        nonce: nonce,
        signedCid: signedCid,
        height: height,
        allGasFee: allGasFee,
      ));
    });
  }
}
