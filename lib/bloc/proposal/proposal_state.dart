part of 'proposal_bloc.dart';

@immutable
class ProposalState extends Equatable {
  final List<TextEditingController> controllers;
  final String methodId;
  final int controllersLength;
  ProposalState({this.controllers, this.methodId, this.controllersLength});

  @override
  // TODO: implement props
  List<Object> get props =>
      [this.controllers, this.methodId, this.controllersLength];

  factory ProposalState.idle() {
    return ProposalState(
      controllers: [TextEditingController()],
      controllersLength: 0,
      methodId: '',
    );
  }

  ProposalState copyWithProposalState({
    List<TextEditingController> controllers,
    String methodId,
    int controllersLength,
  }) {
    return ProposalState(
      controllersLength: controllersLength ?? this.controllersLength,
      methodId: methodId ?? this.methodId,
      controllers: controllers ?? this.controllers,
    );
  }
}
