part of 'address_bloc.dart';

@immutable
class AddressEvent {
  const AddressEvent();
}

class SetAddressEvent extends AddressEvent {
  final List<Wallet> list;
  SetAddressEvent({this.list});
}

class UpdateEvent extends AddressEvent {
  final Wallet wallet;
  UpdateEvent({this.wallet});
}

class DeleteEvent extends AddressEvent {
  final Wallet wallet;
  DeleteEvent({this.wallet});
}
