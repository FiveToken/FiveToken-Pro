import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/models/message.dart';
import 'package:meta/meta.dart';

part 'push_event.dart';
part 'push_state.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  PushBloc() : super(PushState.idle()) {
    on<PushEvent>((event, emit) async {});
    on<SetPushEvent>((event, emit) {
      emit(state.copy(event.message, event.showDisplay));
    });
  }
}
