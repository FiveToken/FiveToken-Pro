part of 'webview_bloc.dart';

@immutable
class WebviewEvent {
  const WebviewEvent();
}

class SetWebviewEvent extends WebviewEvent {
  final bool showWebview;
  final bool loaded;
  SetWebviewEvent({this.showWebview, this.loaded});
}
