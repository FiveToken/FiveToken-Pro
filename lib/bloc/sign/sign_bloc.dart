import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/models/message.dart';
import 'package:meta/meta.dart';

part 'sign_event.dart';
part 'sign_state.dart';

class SignBloc extends Bloc<SignEvent, SignState> {
  SignBloc() : super(SignState.idle()) {
    on<SignEvent>((event, emit) async {});
    on<SetSignEvent>((event, emit) {
      emit(state.copy(event.message, event.signedMessage, event.showSigned));
    });
  }
}
