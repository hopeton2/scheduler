import 'package:flutter/material.dart';

import 'event_grid.dart';

class TimelineEventGrid extends EventGrid {
  const TimelineEventGrid({
    super.key,
    required super.date,
    required super.dayCount,
    required super.constraints,
    required super.intervalWidth,
    required super.showCurrentTimeIndicator,
    required super.intervalType,
    required super.calendarViewType,
    required super.gridHelper,
  }) : super(
          intervalHeight: 0,
          orientation: Axis.horizontal,
          rowCount: 1,
          rowHeaderWidth: 0,
        );

  @override
  TimelineEventGridState createState() => TimelineEventGridState();
}

class TimelineEventGridState extends EventGridState {
  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}
