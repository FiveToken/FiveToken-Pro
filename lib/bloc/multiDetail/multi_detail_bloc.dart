import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/common/global.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/cupertino.dart';

part 'multi_detail_event.dart';
part 'multi_detail_state.dart';

class MultiDetailBloc extends Bloc<MultiDetailEvent, MultiDetailState> {
  MultiDetailBloc() : super(MultiDetailState.idle()) {
    on<getMultiMessageDetailEvent>((event, emit) async {
      var res = await Global.provider.getMultiInfo(event.address);
      var signers = res.signerMap.keys.toList();
      $store.multiWal.signers = signers;
      $store.setMultiWallet($store.multiWal);
      emit(state.copyWithMultiDetailState(signers: signers));
    });
  }
}
