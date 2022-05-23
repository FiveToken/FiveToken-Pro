part of 'init_bloc.dart';

@immutable
class InitState extends Equatable {
  final num level;
  InitState({this.level});
  factory InitState.idle() {
    return InitState(
      level: 0,
    );
  }
  @override
  // TODO: implement props
  List<Object> get props => [level];

  InitState copy(num level) {
    return InitState(level: level ?? this.level);
  }
}
