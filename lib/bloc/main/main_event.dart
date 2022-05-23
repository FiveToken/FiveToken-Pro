part of 'main_bloc.dart';

@immutable
class MainEvent {
  const MainEvent();
}

class getPriceEvent extends MainEvent {
  getPriceEvent();
}

class setSelectTypeEvent extends MainEvent {
  final String selectType;
  setSelectTypeEvent(this.selectType);
}

class getMinerRelatedListEvent extends MainEvent {
  final String address;
  getMinerRelatedListEvent(this.address);
}

class getPowerInfoEvent extends MainEvent {
  final String address;
  getPowerInfoEvent(this.address);
}

class getWalletSortedMessagesEvent extends MainEvent {
  getWalletSortedMessagesEvent();
}

class updateBalanceEvent extends MainEvent {
  final String address;
  updateBalanceEvent(this.address);
}

class updateTransferTypeEvent extends MainEvent {
  final int transferType;
  updateTransferTypeEvent(this.transferType);
}

class getMinerYesterdayInfoEvent extends MainEvent {
  final String address;
  getMinerYesterdayInfoEvent(this.address);
}

class getMinerBalanceInfoEvent extends MainEvent {
  final String address;
  getMinerBalanceInfoEvent(this.address);
}

class updateEnablePullUpEvent extends MainEvent {
  final bool enablePullUp;
  updateEnablePullUpEvent(this.enablePullUp);
}


class getLatestMessageEvent extends MainEvent {
  final String direction;
  getLatestMessageEvent(this.direction);
}


class getMessagesBeforeLastCompletedMessageEvent extends MainEvent {
  final String mid;
  final String direction;
  getMessagesBeforeLastCompletedMessageEvent(this.direction,this.mid);
}


