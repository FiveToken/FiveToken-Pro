part of 'detail_bloc.dart';

@immutable
class DetailEvent {
  const DetailEvent();
}

class getMessageDetailEvent extends DetailEvent {
  final StoreMessage message;
  getMessageDetailEvent(this.message);
}
