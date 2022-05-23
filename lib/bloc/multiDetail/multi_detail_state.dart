part of 'multi_detail_bloc.dart';

@immutable
class MultiDetailState extends Equatable {
  final List signers;
  MultiDetailState({this.signers});

  @override
  // TODO: implement props
  List<Object> get props => [this.signers];

  factory MultiDetailState.idle() {
    return MultiDetailState(
      signers: [],
    );
  }

  MultiDetailState copyWithMultiDetailState({
    List signers,
  }) {
    print('er');
    return MultiDetailState(signers: signers ?? this.signers);
  }
}
