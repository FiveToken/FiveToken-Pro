part of 'detail_bloc.dart';

@immutable
class DetailState extends Equatable {
  final String from;
  final String to;
  final num nonce;
  final num height;
  final String value;
  final num pending;
  final String methodName;
  final String allGasFee;
  final String signedCid;
  final args;
  final returns;
  DetailState(
      {this.from,
      this.to,
      this.nonce,
      this.height,
      this.value,
      this.pending,
      this.methodName,
      this.allGasFee,
      this.signedCid,
      this.args,
      this.returns});

  @override
  // TODO: implement props
  List<Object> get props => [
        this.from,
        this.to,
        this.nonce,
        this.height,
        this.value,
        this.pending,
        this.methodName,
        this.allGasFee,
        this.signedCid,
        this.args,
        this.returns
      ];

  factory DetailState.idle() {
    return DetailState(
      from: '',
      to: '',
      nonce: 0,
      height: 0,
      value: '0',
      pending: 1,
      methodName: '',
      allGasFee: '0',
      signedCid: '',
      args: {},
      returns: {},
    );
  }

  DetailState copyWithDetailState(
      {String from,
      String to,
      num nonce,
      num height,
      String value,
      num pending,
      String methodName,
      String allGasFee,
      String signedCid,
      dynamic args,
      dynamic returns}) {
    print('er');
    return DetailState(
        from: from ?? this.from,
        to: to ?? this.to,
        nonce: nonce ?? this.nonce,
        height: height ?? this.height,
        value: value ?? this.value,
        pending: pending ?? this.pending,
        methodName: methodName ?? this.methodName,
        allGasFee: allGasFee ?? this.allGasFee,
        signedCid: signedCid ?? this.signedCid,
        args: args ?? this.args,
        returns: returns ?? this.returns);
  }
}
