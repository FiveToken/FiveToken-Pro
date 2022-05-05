import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'unsign_event.dart';
part 'unsign_state.dart';

class UnsignBloc extends Bloc<UnsignEvent, UnsignState> {
  UnsignBloc() : super(UnsignState.idle()) {
    on<UnsignEvent>((event, emit) async {});
    on<SetUnsignEvent>((event, emit) {
      emit(state.copy(event.advanced));
    });
  }
}
