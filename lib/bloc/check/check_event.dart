part of 'check_bloc.dart';

@immutable
class CheckEvent {
  const CheckEvent();
}

class SetCheckEvent extends CheckEvent {
  final List<String> unSelectedList;
  final List<String> selectedList;
  SetCheckEvent({this.unSelectedList, this.selectedList});
}

class UpdateEvent extends CheckEvent {
  final int type;
  UpdateEvent({this.type});
}

class DeleteEvent extends CheckEvent {
  final int type;
  DeleteEvent({this.type});
}
