import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'init_event.dart';
part 'init_state.dart';

class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc() : super(InitState.idle()) {
    on<InitEvent>((event, emit) async {});
    on<SetInitEvent>((event, emit) {
      emit(state.copy(event.level));
    });
  }
}
