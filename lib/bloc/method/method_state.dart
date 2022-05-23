part of 'method_bloc.dart';

@immutable
class MethodState extends Equatable {
  final bool hideMethods;
  final String method;
  final bool custom;
  MethodState({this.method, this.custom, this.hideMethods});
  factory MethodState.idle() {
    return MethodState(
      method: '',
      custom: false,
      hideMethods: false,
    );
  }
  @override
  // TODO: implement props
  List<Object> get props => [method, custom, hideMethods];

  MethodState copy({String method, bool custom, bool hideMethods}) {
    return MethodState(
        method: method ?? this.method,
        custom: custom ?? this.custom,
        hideMethods: hideMethods ?? this.hideMethods);
  }
}
