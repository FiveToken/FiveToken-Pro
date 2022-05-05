part of 'make_bloc.dart';

@immutable
class MakeState extends Equatable {
  final String sealType;
  final String method;
  final List<TextEditingController> controllers;
  MakeState({this.sealType, this.method, this.controllers});
  factory MakeState.idle() {
    return MakeState(sealType: '8', method: '0', controllers: []);
  }
  @override
  // TODO: implement props
  List<Object> get props => [sealType, method, controllers];

  MakeState copy(
      {String sealType,
      String method,
      List<TextEditingController> controllers}) {
    return MakeState(
        sealType: sealType ?? this.sealType,
        method: method ?? this.method,
        controllers: controllers ?? this.controllers);
  }
}
