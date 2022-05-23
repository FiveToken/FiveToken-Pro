part of 'multi_bloc.dart';

class MultiEvent {
  const MultiEvent();
}

class getMultiInfoEvent extends MultiEvent {
  final String id;
  getMultiInfoEvent(this.id);
}

class updateSelectTypeEvent extends MultiEvent {
  final int selectType;
  updateSelectTypeEvent(this.selectType);
}

class getWalletSortedMessagesEvent extends MultiEvent {
  final int selectType;
  getWalletSortedMessagesEvent(this.selectType);
}

class getLatestMessagesEvent extends MultiEvent {
  final int selectType;
  getLatestMessagesEvent(this.selectType);
}

class getMessagesBeforeLastCompletedMessageEvent extends MultiEvent {
  final int selectType;
  final String mid;
  final String direction;
  getMessagesBeforeLastCompletedMessageEvent(this.selectType, this.mid, this.direction);
}
