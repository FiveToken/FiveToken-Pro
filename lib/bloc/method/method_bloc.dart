import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:meta/meta.dart';

part 'method_event.dart';
part 'method_state.dart';

class MethodBloc extends Bloc<MethodEvent, MethodState> {
  MethodBloc() : super(MethodState.idle()) {
    on<initMethodEvent>((event, emit) async {
      var args = Get.arguments;
      List<String> _methods = [
        '0',
        '16',
        '23',
        '3',
        '21',
        '2',
      ];

      if (args != null && args['method'] != null) {
        String method = args['method'] as String;
        bool hideMethods = false;
        bool custom = false;
        if (args['hideMethods'] != null && args['hideMethods'] == true) {
          hideMethods = true;
        }
        if (!_methods.contains(method)) {
          custom = true;
        }
        emit(state.copy(
            method: method, custom: custom, hideMethods: hideMethods));
      }
    });

    on<SetMethodEvent>((event, emit) {
      emit(state.copy(method: event.method));
    });

    on<SetCustomEvent>((event, emit) {
      emit(state.copy(custom: event.custom));
    });
  }
}
