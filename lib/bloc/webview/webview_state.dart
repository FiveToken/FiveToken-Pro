part of 'webview_bloc.dart';

@immutable
class WebviewState extends Equatable {
  final bool showWebview;
  final bool loaded;
  WebviewState({this.showWebview, this.loaded});
  factory WebviewState.idle() {
    return WebviewState(showWebview: false, loaded: false);
  }
  @override
  // TODO: implement props
  List<Object> get props => [showWebview, loaded];

  WebviewState copy(bool showWebview, bool loaded) {
    return WebviewState(
        showWebview: showWebview ?? this.showWebview,
        loaded: loaded ?? this.loaded);
  }
}
