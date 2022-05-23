part of 'mne_bloc.dart';

@immutable
class MneState extends Equatable {
  final String mne;
  MneState({this.mne});
  factory MneState.idle() {
    return MneState(mne: '');
  }
  @override
  // TODO: implement props
  List<Object> get props => [mne];

  MneState copy(String mne) {
    return MneState(mne: mne ?? this.mne);
  }
}
