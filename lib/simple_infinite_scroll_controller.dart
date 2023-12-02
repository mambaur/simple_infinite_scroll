import 'package:flutter/material.dart';

class SimpleInfiniteScrollController extends ScrollController {
  static final Map<ScrollController, VoidCallback> _callbacks = {};

  void attachRefreshCallback(VoidCallback callback) {
    _callbacks[this] = callback;
  }

  void refresh() {
    _callbacks[this]?.call();
  }
}
