import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/common/global.dart';
import 'package:fil/update/index.dart';
import 'package:meta/meta.dart';
part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingState.idle()) {
    on<initApkEvent>((event, emit) async {
      if (Global.online) {
        var apk = await checkNeedUpdate();
        emit(state.copy(apk));
      }
    });
  }
}
