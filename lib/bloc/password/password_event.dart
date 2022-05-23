part of 'password_bloc.dart';

@immutable
class PasswordEvent {
  const PasswordEvent();
}

class SetPasswordEvent extends PasswordEvent {
  final bool passShow;
  SetPasswordEvent({this.passShow});
}
