part of 'setting_bloc.dart';

@immutable
class SettingState extends Equatable {
  final ApkInfo apk;
  SettingState({this.apk});
  factory SettingState.idle() {
    return SettingState(apk: ApkInfo());
  }
  @override
  // TODO: implement props
  List<Object> get props => [apk];

  SettingState copy(ApkInfo apk) {
    return SettingState(apk: apk ?? this.apk);
  }
}
