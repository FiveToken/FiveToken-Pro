part of 'multi_detail_bloc.dart';

class MultiDetailEvent {
  const MultiDetailEvent();
}

class getMultiMessageDetailEvent extends MultiDetailEvent {
  final String address;
  getMultiMessageDetailEvent(this.address);
}
