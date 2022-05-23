part of 'push_bloc.dart';

@immutable
class PushEvent {
  const PushEvent();
}

class SetPushEvent extends PushEvent {
  final SignedMessage message;
  final bool showDisplay;
  SetPushEvent({this.message, this.showDisplay});
}
