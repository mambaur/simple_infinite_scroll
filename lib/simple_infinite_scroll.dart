// ignore_for_file: library_private_types_in_public_api

library simple_infinite_scroll;

import 'package:flutter/material.dart';
part 'models/refresh_indicator_style.dart';
part 'simple_infinite_scroll_controller.dart';

class SimpleInfiniteScroll<T> extends StatefulWidget {
  final Widget? Function(BuildContext context, int index, T item) itemBuilder;
  final SimpleInfiniteScrollController? controller;
  final SimpleInfiniteScrollController? externalController;
  final int? initialPage;
  final int? limit;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final bool? shrinkWrap;
  final ScrollPhysics? physics;
  final Future<List<T>?> Function(int page, int limit) fetch;
  final bool? primary;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Widget? prototypeItem;
  final int? Function(Key)? findChildIndexCallback;
  final double? cacheExtent;
  final int? semanticChildCount;
  final String? restorationId;
  final Widget? loadingInitialWidget;
  final Function()? onRefresh;
  final void Function(dynamic error)? onError;
  final RefreshIndicatorStyle? refreshIndicatorStyle;

  const SimpleInfiniteScroll(
      {Key? key,
      this.loadingInitialWidget,
      this.primary,
      this.padding,
      this.emptyWidget,
      this.itemExtent,
      this.refreshIndicatorStyle,
      this.prototypeItem,
      this.onRefresh,
      this.findChildIndexCallback,
      this.cacheExtent,
      this.semanticChildCount,
      this.restorationId,
      required this.itemBuilder,
      required this.fetch,
      this.loadingWidget,
      this.limit = 10,
      this.shrinkWrap,
      this.physics,
      this.controller,
      this.onError,
      this.externalController,
      this.initialPage = 1})
      : super(key: key);

  @override
  _SimpleInfiniteScrollState createState() => _SimpleInfiniteScrollState<T>();
}

class _SimpleInfiniteScrollState<T> extends State<SimpleInfiniteScroll<T>> {
  final SimpleInfiniteScrollController _scrollController =
      SimpleInfiniteScrollController();

  final List<T> _items = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _limit = 10;
  bool _hasMore = true;
  bool _isInit = true;
  bool _isEmpty = false;

  @override
  void initState() {
    _currentPage = widget.initialPage ?? 1;
    _limit = widget.limit ?? 10;

    super.initState();
    if (widget.externalController != null) {
      widget.externalController!.addListener(onScroll);
      widget.externalController!.attachRefreshCallback(_refresh);
    } else {
      (widget.controller ?? _scrollController).addListener(onScroll);
      (widget.controller ?? _scrollController).attachRefreshCallback(_refresh);
    }
    _initData();
  }

  @override
  void dispose() {
    if (widget.externalController != null) {
      widget.externalController!.dispose();
    } else {
      (widget.controller ?? _scrollController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInit && widget.loadingInitialWidget != null
        ? widget.loadingInitialWidget!
        : RefreshIndicator(
            displacement: widget.refreshIndicatorStyle?.displacement ?? 40.0,
            edgeOffset: widget.refreshIndicatorStyle?.edgeOffset ?? 0.0,
            strokeWidth: widget.refreshIndicatorStyle?.strokeWidth ??
                RefreshProgressIndicator.defaultStrokeWidth,
            triggerMode: widget.refreshIndicatorStyle?.triggerMode ??
                RefreshIndicatorTriggerMode.onEdge,
            notificationPredicate:
                widget.refreshIndicatorStyle?.notificationPredicate ??
                    defaultScrollNotificationPredicate,
            semanticsLabel: widget.refreshIndicatorStyle?.semanticsLabel,
            semanticsValue: widget.refreshIndicatorStyle?.semanticsValue,
            color: widget.refreshIndicatorStyle?.color,
            backgroundColor: widget.refreshIndicatorStyle?.backgroundColor,
            onRefresh: () async {
              if (widget.onRefresh != null) {
                widget.onRefresh!();
              }
              await _refresh();
            },
            child: _isEmpty && widget.emptyWidget != null
                ? widget.emptyWidget!
                : ListView.builder(
                    controller: widget.externalController != null
                        ? null
                        : (widget.controller ?? _scrollController),
                    physics: widget.physics,
                    itemCount: _hasMore ? _items.length + 1 : _items.length,
                    shrinkWrap: widget.shrinkWrap ?? true,
                    primary: widget.primary,
                    padding: widget.padding,
                    itemExtent: widget.itemExtent,
                    prototypeItem: widget.prototypeItem,
                    findChildIndexCallback: widget.findChildIndexCallback,
                    cacheExtent: widget.cacheExtent,
                    semanticChildCount: widget.semanticChildCount,
                    restorationId: widget.restorationId,
                    itemBuilder: (context, index) {
                      if (index < _items.length) {
                        return widget.itemBuilder(
                            context, index, _items[index]);
                      }
                      return widget.loadingWidget ??
                          const Center(child: CircularProgressIndicator());
                    }),
          );
  }

  void onScroll() async {
    if (isMaxScroll() && _hasMore) {
      await _fetchData();
    }
  }

  bool isMaxScroll() {
    if (_isEmpty || _isInit) return false;

    if (widget.externalController != null) {
      double maxScroll = widget.externalController!.position.maxScrollExtent;
      double currentScroll = widget.externalController!.position.pixels;
      return currentScroll == maxScroll;
    } else {
      double maxScroll =
          (widget.controller ?? _scrollController).position.maxScrollExtent;
      double currentScroll =
          (widget.controller ?? _scrollController).position.pixels;
      return currentScroll == maxScroll;
    }
  }

  Future<void> _fetchData() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      List<T>? data = await widget.fetch(_currentPage, _limit);
      if (data != null) {
        _items.addAll(data);
        _currentPage++;
      }

      if (data!.length < _limit) {
        _hasMore = false;
      }

      if (data.isEmpty && _isInit) _isEmpty = true;
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(e);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isInit = false;
      });
    }
  }

  Future<void> _refresh() async {
    if (_isLoading) {
      return;
    }
    _items.clear();
    setState(() {});
    _currentPage = widget.initialPage ?? 1;
    _hasMore = true;
    _isInit = true;
    _isEmpty = false;
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
    await _initData();
  }

  Future _initData() async {
    await _fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkScroll();
    });
  }

  checkScroll() {
    if (isMaxScroll() && _items.length == _limit) _fetchData();
  }
}
