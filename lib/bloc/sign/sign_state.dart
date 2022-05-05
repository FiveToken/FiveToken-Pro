part of 'sign_bloc.dart';

@immutable
class SignState extends Equatable {
  final TMessage message;
  final SignedMessage signedMessage;
  final bool showSigned;
  SignState({this.message, this.signedMessage, this.showSigned});
  factory SignState.idle() {
    return SignState(
        message: TMessage(), signedMessage: null, showSigned: false);
  }
  @override
  // TODO: implement props
  List<Object> get props => [message, signedMessage, showSigned];

  SignState copy(
      TMessage message, SignedMessage signedMessage, bool showSigned) {
    return SignState(
        message: message ?? this.message,
        signedMessage: signedMessage ?? this.signedMessage,
        showSigned: showSigned ?? this.showSigned);
  }
}
