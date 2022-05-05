part of 'mne_bloc.dart';

@immutable
class MneEvent {
  const MneEvent();
}

class SetMneEvent extends MneEvent {
  final String mne;
  SetMneEvent({this.mne});
}
