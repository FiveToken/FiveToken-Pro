part of 'reset_bloc.dart';

@immutable
class ResetEvent {
  const ResetEvent();
}

class SetResetEvent extends ResetEvent {
  final num level;
  SetResetEvent({this.level});
}
