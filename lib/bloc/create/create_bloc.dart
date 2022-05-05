import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'create_event.dart';
part 'create_state.dart';

class CreateBloc extends Bloc<CreateEvent, CreateState> {
  CreateBloc() : super(CreateState.idle()) {
    on<CreateEvent>((event, emit) async {});
    on<SetCreateEvent>((event, emit) {
      emit(state.copy(event.singers));
    });
    on<UpdateEvent>((event, emit) {
      List<TextEditingController> singers = state.signers;
      singers.removeAt(event.type);
      emit(state.copy(singers));
    });
    on<DeleteEvent>((event, emit) {
      List<TextEditingController> singers = state.signers;
      singers.removeAt(event.type);
      emit(state.copy(singers));
    });
  }
}
