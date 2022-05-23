part of 'create_bloc.dart';

@immutable
class CreateEvent {
  const CreateEvent();
}

class SetCreateEvent extends CreateEvent {
  final List<TextEditingController> singers;
  SetCreateEvent({this.singers});
}

class UpdateEvent extends CreateEvent {
  final int type;
  UpdateEvent({this.type});
}

class DeleteEvent extends CreateEvent {
  final int type;
  DeleteEvent({this.type});
}
