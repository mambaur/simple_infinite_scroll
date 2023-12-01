library simple_infinite_scroll;

import 'package:flutter/material.dart';

class SimpleInfiniteScroll<T> extends StatefulWidget {
  final Widget? Function(BuildContext context, int index, T item) itemBuilder;
  final ScrollController? controller;
  final int? initialPage;
  final int? limit;
  final Widget? loadingWidget;
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
  final Function()? onLoadingInitial;
  final void Function(dynamic error)? onError;

  const SimpleInfiniteScroll(
      {Key? key,
      this.loadingInitialWidget,
      this.onLoadingInitial,
      this.primary,
      this.padding,
      this.itemExtent,
      this.prototypeItem,
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
      this.initialPage = 1})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SimpleInfiniteScrollState createState() => _SimpleInfiniteScrollState<T>();
}

class _SimpleInfiniteScrollState<T> extends State<SimpleInfiniteScroll<T>> {
  final ScrollController _scrollController = ScrollController();

  final List<T> _items = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _limit = 10;
  bool _hasMore = true;
  bool _isInit = true;

  void onScroll() async {
    if (isMaxScroll() && _hasMore) {
      await _fetchData();
    }
  }

  bool isMaxScroll() {
    double maxScroll =
        (widget.controller ?? _scrollController).position.maxScrollExtent;
    double currentScroll =
        (widget.controller ?? _scrollController).position.pixels;
    return currentScroll == maxScroll;
  }

  Future<void> _fetchData() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    if (_isInit && widget.onLoadingInitial != null) {
      widget.onLoadingInitial;
    }

    try {
      List<T>? data = await widget.fetch(_currentPage, _limit);
      if (data != null) {
        _items.addAll(data);
        _currentPage++;
      }

      if (data!.length < _limit) {
        _hasMore = false;
      }
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
    _items.clear();
    setState(() {});
    _currentPage = widget.initialPage ?? 1;
    _hasMore = true;
    await _initData();
  }

  @override
  void initState() {
    _currentPage = widget.initialPage ?? 1;
    _limit = widget.limit ?? 10;

    super.initState();
    (widget.controller ?? _scrollController).addListener(onScroll);

    _initData();
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

  @override
  void dispose() {
    (widget.controller ?? _scrollController).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInit && widget.loadingInitialWidget != null
        ? widget.loadingInitialWidget!
        : RefreshIndicator(
            onRefresh: () async {
              await _refresh();
            },
            child: ListView.builder(
                controller: widget.controller ?? _scrollController,
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
                    return widget.itemBuilder(context, index, _items[index]);
                  }
                  return widget.loadingWidget ??
                      const Center(child: CircularProgressIndicator());
                }),
          );
  }
}
