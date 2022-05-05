import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/wallet.dart';
import 'package:meta/meta.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(AddressState.idle()) {
    on<AddressEvent>((event, emit) async {});
    on<SetAddressEvent>((event, emit) {
      var box = OpenedBox.addressBookInsance;
      List<Wallet> list = box.values.toList() as List<Wallet>;
      emit(state.copy(list));
    });
    on<UpdateEvent>((event, emit) {
      var box = OpenedBox.addressBookInsance;
      box.put(event.wallet.address, event.wallet);
      List<Wallet> list = box.values.toList() as List<Wallet>;
      emit(state.copy(list));
    });
    on<DeleteEvent>((event, emit) {
      var box = OpenedBox.addressBookInsance;
      box.delete(event.wallet.address);
      List<Wallet> list = box.values.toList() as List<Wallet>;
      emit(state.copy(list));
    });
  }
}
