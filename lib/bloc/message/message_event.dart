part of 'message_bloc.dart';

class MessageEvent {
  const MessageEvent();
}

class addControllersEvent extends MessageEvent {
  addControllersEvent();
}

class removeControllersEvent extends MessageEvent {
  final int index;
  removeControllersEvent(this.index);
}

class setControllersEvent extends MessageEvent {
  setControllersEvent();
}

class initMethodEvent extends MessageEvent {
  initMethodEvent();
}

class setMethodEvent extends MessageEvent {
  final String method;
  setMethodEvent(this.method);
}

class setMessageEvent extends MessageEvent {
  final SignedMessage message;
  setMessageEvent(this.message);
}

class setShowDisplayEvent extends MessageEvent {
  final bool showDisplay;
  setShowDisplayEvent(this.showDisplay);
}

class setSealTypeEvent extends MessageEvent {
  final String sealType;
  setSealTypeEvent(this.sealType);
}

class setRadioTypeEvent extends MessageEvent {
  final String radioType;
  setRadioTypeEvent(this.radioType);
}

class initDepositEvent extends MessageEvent {
  initDepositEvent();
}
