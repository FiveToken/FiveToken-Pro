import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/models/message.dart';
import 'package:fil/pages/message/make.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageState.idle()) {
    //
    on<setRadioTypeEvent>((event, emit) {
      emit(state.copyWithMessageState(radioType: event.radioType));
    });

    on<setMessageEvent>((event, emit) {
      emit(state.copyWithMessageState(message: event.message));
    });

    on<setSealTypeEvent>((event, emit) {
      emit(state.copyWithMessageState(sealType: event.sealType));
    });

    on<setShowDisplayEvent>((event, emit) {
      emit(state.copyWithMessageState(showDisplay: event.showDisplay));
    });

    on<removeControllersEvent>((event, emit) {
      List<TextEditingController> controllers = state.controllers;
      controllers.removeAt(event.index);
      emit(state.copyWithMessageState(
          controllers: controllers,
          controllersLength: controllers.length ?? 0));
    });

    on<setControllersEvent>((event, emit) {
      if (Get.arguments != null) {
        if (Get.arguments['params'] is Map) {
          var params = Get.arguments['params'] as Map;
          var innerParams = Get.arguments['innerParams'];
          var method = params['Method'].toString();
          if (method == '3') {
            var newWorker = innerParams['NewWorker'];
            var newCtrls = innerParams['NewControlAddrs'];
            if (newWorker is String && newCtrls is List) {
              final List<TextEditingController> controllers = List.generate(
                  newCtrls.length,
                  (index) =>
                      TextEditingController(text: newCtrls[index] as String));
              emit(state.copyWithMessageState(
                  controllers: controllers,
                  controllersLength: controllers.length ?? 0));
            }
          }
        }
      }
    });
  }
}
