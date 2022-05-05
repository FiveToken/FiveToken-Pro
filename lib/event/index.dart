class AppStateChangeEvent {}

class ShouldRefreshEvent {
  String refreshKey;
  ShouldRefreshEvent({this.refreshKey});
}

class GasConfirmEvent {}

class AccountChangeEvent {}
