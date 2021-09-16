import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef FreshCallback = Future Function();

class CustomRefreshWidget extends StatefulWidget {
  final Widget child;
  final bool enablePullDown;
  final bool enablePullUp;
  final bool listenAppState;
  final bool initRefresh;
  final FreshCallback onRefresh;
  final FreshCallback onLoading;
  final String refreshKey;
  CustomRefreshWidget(
      {@required this.child,
      this.enablePullUp = true,
      this.enablePullDown = true,
      this.listenAppState = true,
      this.initRefresh = false,
      this.onLoading,
      this.refreshKey,
      @required this.onRefresh});
  @override
  State<StatefulWidget> createState() {
    return CustomRefreshWidgetState();
  }
}

class CustomRefreshWidgetState extends State<CustomRefreshWidget> {
  final RefreshController controller = RefreshController();
  @override
  void initState() {
    super.initState();
    nextTick(() {
      if (widget.initRefresh) {
        controller.requestRefresh();
      }
    });
    if (widget.listenAppState) {
      Global.eventBus.on<AppStateChangeEvent>().listen((event) {
        controller.requestRefresh();
      });
    }
    Global.eventBus.on<ShouldRefreshEvent>().listen((event) {
      if (event.refreshKey == widget.refreshKey) {
        controller.requestRefresh();
      }
    });
  }

  void _onRefresh() async {
    Timer timer = Timer(Duration(seconds: 10), () {
      controller.refreshFailed();
    });
    try {
      await widget.onRefresh();
      timer.cancel();
      controller.refreshCompleted();
    } catch (e) {
      controller.refreshFailed();
    }
  }

  void _onLoading() async {
    Timer timer = Timer(Duration(seconds: 10), () {
      controller.loadFailed();
    });
    try {
      await widget.onLoading();
      timer.cancel();
      controller.loadComplete();
    } catch (e) {
      controller.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      footer: CustomFooter(builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text('loadMore'.tr);
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text('loadFail'.tr);
        } else if (mode == LoadStatus.canLoading) {
          body = Text('loadMore'.tr);
        } else {
          body = Text("noMore".tr);
        }
        return Center(
          child: body,
        );
      }),
      header: WaterDropHeader(
        waterDropColor: CustomColor.primary,
        complete: Text('finish'.tr),
        failed: Text('loadFail'.tr),
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
