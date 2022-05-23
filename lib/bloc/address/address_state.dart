part of 'address_bloc.dart';

@immutable
class AddressState extends Equatable {
  final List<Wallet> list;
  AddressState({this.list});
  factory AddressState.idle() {
    return AddressState(
      list: [],
    );
  }
  @override
  // TODO: implement props
  List<Object> get props => [list];

  AddressState copy(
    List<Wallet> list,
  ) {
    return AddressState(
      list: list ?? this.list,
    );
  }
}
