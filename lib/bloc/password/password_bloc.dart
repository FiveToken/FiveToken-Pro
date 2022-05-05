import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:meta/meta.dart';

part 'password_event.dart';
part 'password_state.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  PasswordBloc() : super(PasswordState.idle()) {
    on<PasswordEvent>((event, emit) async {});
    on<SetPasswordEvent>((event, emit) {
      emit(state.copy(event.passShow));
    });
  }
}
