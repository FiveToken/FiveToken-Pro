import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

part 'proposal_event.dart';
part 'proposal_state.dart';

class ProposalBloc extends Bloc<ProposalEvent, ProposalState> {
  ProposalBloc() : super(ProposalState.idle()) {
    on<addControllersEvent>((event, emit) {
      List<TextEditingController> controllers = state.controllers;
      controllers.add(TextEditingController());
      emit(state.copyWithProposalState(
          controllers: controllers, controllersLength: controllers.length ?? 0
          // timestamp:DateTime.now().microsecondsSinceEpoch
          ));
    });

    on<removeControllersEvent>((event, emit) {
      List<TextEditingController> controllers = state.controllers;
      controllers.removeAt(event.index);
      emit(state.copyWithProposalState(
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
              emit(state.copyWithProposalState(
                  controllers: controllers,
                  controllersLength: controllers.length ?? 0));
            }
          }
        }
      }
    });
  }
}
