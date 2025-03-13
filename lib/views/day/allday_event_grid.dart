import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/common/scheduler_view_helper.dart';
import 'package:scheduler/extensions/date_extensions.dart';

import '../../scheduler.dart';
import '../../services/appointment_render_service.dart';
import '../../services/event_layout_manager.dart';
import '../../services/services.dart';

import '../../widgets/event_grid/event_grid.dart';
import '../../widgets/scheduler_grid/grid_helper.dart';

class AlldayEventGrid extends StatefulWidget {
  final int colCount;
  final DateTime startDate;
  final BoxConstraints constraints;
  final IntervalType intervalType;
  final double timebarWidth;

  const AlldayEventGrid({
    super.key,
    required this.colCount,
    required this.startDate,
    required this.constraints,
    required this.intervalType,
    required this.timebarWidth,
  });

  @override
  State<AlldayEventGrid> createState() => AlldayEventGridState();
}

class AlldayEventGridState extends State<AlldayEventGrid> {
  ({DateTime start, DateTime end}) incCellDates(int index) {
    DateTime start = widget.startDate.incDays(index).startOfDay;
    DateTime end = start.endOfDay;
    return (start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    GridHelper gridHelper = GridHelper(
      incrementRowDate: (int index) => widget.startDate,
      incrementCellDate: (date, index) => date.incDays(index).startOfDay,
      showCellDate: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewService.allDayRect = uiService.getBounds(context);
    });
    return Container(
      color: schedulerService.scheduler.dayViewSettings.allDayBackgroundColor,
      height: 100,
      child: EventGrid(
        key: UniqueKey(),
        isAllDayGrid: true,
        gridHelper: gridHelper,
        eventLayoutHandler:
            (Rect rect, AppointmentRenderService renderService) =>
                EventLayoutManager(
          gridHelper: gridHelper,
          renderService: renderService,
          cellTopOffset: 8,
          initialDate: widget.startDate,
          colCount: widget.colCount,
          rowCount: 1,
          calendarRect: rect,
          orientation: Axis.horizontal,
          incCellDate: (DateTime date, int index) => incCellDates(index),
          events: schedulerService.scheduler.dataSource!
              .visibleAppointmentItemsByDateRange(widget.startDate.startOfDay,
                  widget.startDate.incDays(widget.colCount - 1).endOfDay)
              .where((element) => element.appointment.isAllDay)
              .toList(),
          fixedSize: 20,
        ).arrangeEvents(),
        showDashLines: false,
        date: widget.startDate,
        dayCount: widget.colCount,
        rowCount: 1,
        colCount: widget.colCount,
        constraints: widget.constraints,
        maxHeight: 100,
        intervalHeight: 100,
        intervalWidth: widget.constraints.maxWidth / widget.colCount,
        showCurrentTimeIndicator: false,
        orientation: Axis.horizontal,
        intervalType: IntervalType.day,
        rowHeaderWidth: widget.timebarWidth,
        calendarViewType: viewNavigationService.viewType,
        cellHeaderBuilder: (BuildContext context, DateTime date, int index) {
          return Visibility(
            visible: !SchedulerViewHelper.isMobileLayout(context),
            child: SizedBox(
              width: widget.timebarWidth,
              child: Text(
                schedulerService.scheduler.dayViewSettings.allDayCaption,
                style: TextStyle(
                  fontSize: 11,
                  color: schedulerService
                      .scheduler.schedulerSettings.timebarFontColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        fixedEventSize: 40,
      ),
    );
  }
}
