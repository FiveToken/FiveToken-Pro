import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:meta/meta.dart';

part 'check_event.dart';
part 'check_state.dart';

class CheckBloc extends Bloc<CheckEvent, CheckState> {
  CheckBloc() : super(CheckState.idle()) {
    on<CheckEvent>((event, emit) async {});
    on<SetCheckEvent>((event, emit) {
      emit(state.copy(event.unSelectedList, event.selectedList));
    });
    on<UpdateEvent>((event, emit) {
      List<String> select = state.selectedList.map((e) => e).toList();
      List<String> unselect = state.unSelectedList.map((e) => e).toList();
      var rm = unselect.removeAt(event.type);
      select.add(rm);
      emit(state.copy(unselect, select));
    });
    on<DeleteEvent>((event, emit) {
      List<String> select = state.selectedList.map((e) => e).toList();
      List<String> unselect = state.unSelectedList.map((e) => e).toList();
      var rm = select.removeAt(event.type);
      unselect.add(rm);
      emit(state.copy(unselect, select));
    });
  }
}
