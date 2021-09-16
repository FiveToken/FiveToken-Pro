class AppStateChangeEvent {}
class ShouldRefreshEvent{
  String refreshKey;
  ShouldRefreshEvent({this.refreshKey});
}