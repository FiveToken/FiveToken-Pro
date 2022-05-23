part of 'password_bloc.dart';

@immutable
class PasswordState extends Equatable {
  final bool passShow;
  PasswordState({this.passShow});
  factory PasswordState.idle() {
    return PasswordState(
      passShow: false,
    );
  }
  @override
  // TODO: implement props
  List<Object> get props => [passShow];

  PasswordState copy(bool passShow) {
    return PasswordState(passShow: passShow ?? this.passShow);
  }
}
