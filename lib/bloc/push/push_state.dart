part of 'push_bloc.dart';

@immutable
class PushState extends Equatable {
  final SignedMessage message;
  final bool showDisplay;
  PushState({this.message, this.showDisplay});
  factory PushState.idle() {
    return PushState(message: null, showDisplay: false);
  }
  @override
  // TODO: implement props
  List<Object> get props => [message, showDisplay];

  PushState copy(SignedMessage message, bool showDisplay) {
    return PushState(
        message: message ?? this.message,
        showDisplay: showDisplay ?? this.showDisplay);
  }
}
