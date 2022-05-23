import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'reset_event.dart';
part 'reset_state.dart';

class ResetBloc extends Bloc<ResetEvent, ResetState> {
  ResetBloc() : super(ResetState.idle()) {
    on<ResetEvent>((event, emit) async {});
    on<SetResetEvent>((event, emit) {
      emit(state.copy(event.level));
    });
  }
}
