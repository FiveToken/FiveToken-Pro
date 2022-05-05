import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'make_event.dart';
part 'make_state.dart';

class MakeBloc extends Bloc<MakeEvent, MakeState> {
  MakeBloc() : super(MakeState.idle()) {
    on<MakeEvent>((event, emit) async {});
    on<SetMakeEvent>((event, emit) {
      emit(state.copy(
          sealType: event.sealType,
          method: event.method,
          controllers: event.controllers));
    });
    on<AddEvent>((event, emit) {
      List<TextEditingController> array = state.controllers;
      array.add(event.worker);
      emit(state.copy(controllers: array));
    });
    on<DeleteEvent>((event, emit) {
      List<TextEditingController> controllers = state.controllers;
      controllers.removeAt(event.type);
      emit(state.copy(controllers: controllers));
    });
  }
}
