part of 'reset_bloc.dart';

@immutable
class ResetState extends Equatable {
  final num level;
  ResetState({this.level});
  factory ResetState.idle() {
    return ResetState(
      level: 0,
    );
  }
  @override
  // TODO: implement props
  List<Object> get props => [level];

  ResetState copy(num level) {
    return ResetState(level: level ?? this.level);
  }
}
