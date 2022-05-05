part of 'proposal_bloc.dart';

class ProposalEvent {
  const ProposalEvent();
}

class addControllersEvent extends ProposalEvent {
  addControllersEvent();
}

class removeControllersEvent extends ProposalEvent {
  final int index;
  removeControllersEvent(this.index);
}

class setControllersEvent extends ProposalEvent {
  setControllersEvent();
}
