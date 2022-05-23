part of 'unsign_bloc.dart';

@immutable
class UnsignState extends Equatable {
  final bool advanced;
  UnsignState({this.advanced});
  factory UnsignState.idle() {
    return UnsignState(advanced: false);
  }
  @override
  // TODO: implement props
  List<Object> get props => [advanced];

  UnsignState copy(bool advanced) {
    return UnsignState(advanced: advanced ?? this.advanced);
  }
}
