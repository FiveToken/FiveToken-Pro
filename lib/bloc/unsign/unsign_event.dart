part of 'unsign_bloc.dart';

@immutable
class UnsignEvent {
  const UnsignEvent();
}

class SetUnsignEvent extends UnsignEvent {
  final bool advanced;
  SetUnsignEvent({this.advanced});
}
