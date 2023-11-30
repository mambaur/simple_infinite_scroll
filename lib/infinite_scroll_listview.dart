library infinite_scroll_listview;

import 'package:flutter/material.dart';

class SimpleInfiniteScroll<T> extends StatefulWidget {
  final Widget? Function(BuildContext, T) itemBuilder;
  final ScrollController? controller;
  final int? pageStartFrom;
  final int? limit;
  final Widget? loadingWidget;
  final bool? shrinkWrap;
  final ScrollPhysics? physics;
  final Future<List<T>?> Function(int page, int limit) fetch;
  const SimpleInfiniteScroll(
      {Key? key,
      required this.itemBuilder,
      required this.fetch,
      this.loadingWidget,
      this.limit = 10,
      this.shrinkWrap,
      this.physics,
      this.controller,
      this.pageStartFrom = 1})
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

    List<T>? data = await widget.fetch(_currentPage, _limit);
    setState(() {
      if (data != null) {
        _items.addAll(data);
        _currentPage++;
        _isLoading = false;
      }

      if (data!.length < _limit) {
        _hasMore = false;
      }
    });
  }

  Future<void> _refresh() async {
    _items.clear();
    setState(() {});
    _currentPage = widget.pageStartFrom ?? 1;
    _hasMore = true;
    await _initData();
  }

  @override
  void initState() {
    _currentPage = widget.pageStartFrom ?? 1;
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
    return RefreshIndicator(
      onRefresh: () async {
        await _refresh();
      },
      child: ListView.builder(
          controller: widget.controller ?? _scrollController,
          physics: widget.physics,
          itemCount: _hasMore ? _items.length + 1 : _items.length,
          shrinkWrap: widget.shrinkWrap ?? true,
          itemBuilder: (context, index) {
            if (index < _items.length) {
              return widget.itemBuilder(context, _items[index]);
            }
            return widget.loadingWidget ??
                const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
