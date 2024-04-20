import 'package:flutter/material.dart';
// Refresh style
class RefreshIndicatorStyle {
  double? displacement, edgeOffset, strokeWidth;
  RefreshIndicatorTriggerMode? triggerMode;
  bool Function(ScrollNotification) notificationPredicate;
  String? semanticsLabel, semanticsValue;
  Color? color, backgroundColor;

  RefreshIndicatorStyle(
      {this.displacement = 40.0,
      this.edgeOffset = 0.0,
      this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
      this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
      this.notificationPredicate = defaultScrollNotificationPredicate,
      this.semanticsLabel,
      this.semanticsValue,
      this.color,
      this.backgroundColor});
}
