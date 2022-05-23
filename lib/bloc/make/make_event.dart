part of 'make_bloc.dart';

@immutable
class MakeEvent {
  const MakeEvent();
}

class SetMakeEvent extends MakeEvent {
  final String sealType;
  final String method;
  final List<TextEditingController> controllers;
  SetMakeEvent({this.sealType, this.method, this.controllers});
}

class AddEvent extends MakeEvent {
  TextEditingController worker;
  AddEvent(this.worker);
}

class DeleteEvent extends MakeEvent {
  final int type;
  DeleteEvent({this.type});
}
