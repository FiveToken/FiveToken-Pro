part of 'sign_bloc.dart';

@immutable
class SignEvent {
  const SignEvent();
}

class SetSignEvent extends SignEvent {
  final TMessage message;
  final SignedMessage signedMessage;
  final bool showSigned;
  SetSignEvent({this.message, this.signedMessage, this.showSigned});
}
