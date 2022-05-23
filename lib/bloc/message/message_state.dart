part of 'message_bloc.dart';

@immutable
class MessageState extends Equatable {
  // make.dart
  final List<TextEditingController> controllers;
  final int controllersLength;
  final String method;
  final String sealType;

  // push.dart
  final SignedMessage message;
  final bool showDisplay;

  // deposit.dart
  final String radioType;
  MessageState({
    this.controllers,
    this.controllersLength,
    this.method,
    this.message,
    this.showDisplay,
    this.sealType,
    this.radioType,
  });

  @override
  // TODO: implement props
  List<Object> get props => [
        this.controllers,
        this.controllersLength,
        this.method,
        this.message,
        this.showDisplay,
        this.sealType,
        this.radioType,
      ];

  factory MessageState.idle() {
    return MessageState(
      controllers: [TextEditingController()],
      controllersLength: 0,
      method: '0',
      message: null,
      showDisplay: false,
      sealType: '8',
      radioType: RechargeRadio.offLine,
    );
  }

  MessageState copyWithMessageState({
    List<TextEditingController> controllers,
    int controllersLength,
    String method,
    SignedMessage message,
    bool showDisplay,
    String sealType,
    String radioType,
  }) {
    return MessageState(
      controllersLength: controllersLength ?? this.controllersLength,
      controllers: controllers ?? this.controllers,
      method: method ?? this.method,
      message: message ?? this.message,
      showDisplay: showDisplay ?? this.showDisplay,
      sealType: sealType ?? this.sealType,
      radioType: radioType ?? this.radioType,
    );
  }
}
