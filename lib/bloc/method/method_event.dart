part of 'method_bloc.dart';

@immutable
class MethodEvent {
  const MethodEvent();
}

class initMethodEvent extends MethodEvent {
  initMethodEvent();
}

class SetMethodEvent extends MethodEvent {
  final String method;
  SetMethodEvent(this.method);
}

class SetCustomEvent extends MethodEvent {
  final bool custom;
  SetCustomEvent(this.custom);
}
