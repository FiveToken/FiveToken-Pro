part of 'init_bloc.dart';

@immutable
class InitEvent {
  const InitEvent();
}

class SetInitEvent extends InitEvent {
  final num level;
  SetInitEvent({this.level});
}
