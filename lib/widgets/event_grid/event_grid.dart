import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/date_range.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/appointment_render_service.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/time_slot.dart';
import 'package:dart_date/dart_date.dart';
import 'package:scheduler/widgets/current_time_indicator.dart';
import 'package:scheduler/widgets/scrollable_stack.dart';


import '../../models/appointment_item.dart';
import '../../services/services.dart';
import '../../widgets/scheduler_grid/scheduler_grid.dart';
import '../scheduler_grid/grid_helper.dart';

class EventGrid extends StatefulWidget {
  final HeaderBuilder? cellHeaderBuilder;
  final double cellHeaderHeight;
  final HeaderBuilder? columnHeaderBuilder;
  final DateTime date;
  final int dayCount;
  final int? rowCount;
  final int? colCount;
  final BoxConstraints constraints;
  final double? maxHeight;
  final double? maxWidth;
  final double intervalWidth;
  final double intervalHeight;
  final bool showCurrentTimeIndicator;
  final bool isAllDayHost;
  final bool isAllDayGrid;
  final Axis orientation;
  final IntervalType intervalType;
  final double rowHeaderWidth;
  final CalendarViewType calendarViewType;
  final WidgetBuilder? gridBuilder;
  final bool showDashLines;
  final GridHelper gridHelper;
  final double fixedEventSize;
  final EventLayoutHandler? eventLayoutHandler;
  final List<AppointmentItem> Function()? getVisibleAppointments;
  final ScrollController? scrollController;
  const EventGrid({
    Key? key,
    required this.date,
    required this.dayCount,
    required this.constraints,
    required this.intervalHeight,
    required this.intervalWidth,
    required this.showCurrentTimeIndicator,
    required this.orientation,
    required this.intervalType,
    required this.rowHeaderWidth,
    required this.calendarViewType,
    required this.gridHelper,
    this.isAllDayGrid = false,
    this.isAllDayHost = false,
    this.showDashLines = true,
    this.fixedEventSize = 0,
    this.colCount,
    this.rowCount,
    this.gridBuilder,
    this.cellHeaderBuilder,
    this.columnHeaderBuilder,
    this.cellHeaderHeight = 0,
    this.eventLayoutHandler,
    this.getVisibleAppointments,
    this.scrollController,
    this.maxHeight,
    this.maxWidth,
  }) : super(key: key); 

  double get height => maxHeight ?? constraints.maxHeight;
  double get width => maxWidth ?? constraints.maxWidth;

  int get interval => schedulerService.dayViewSettings.intervalMinute.value;
  int get slotsPerTimeBlock => 60 ~/ interval;
  int get intervalCount => slotsPerTimeBlock * 24;

  @override
  EventGridState createState() => EventGridState();
}

class EventGridState extends State<EventGrid> {
  AppointmentRenderService? appointmentRenderService;
  final List<TimeSlot> timeSlots = [];
  final Scheduler scheduler = SchedulerService.instance.scheduler;
  final SchedulerDataSource dataSource = SchedulerService.instance.scheduler.dataSource!;
  late final scrollController = widget.scrollController ?? ScrollController(initialScrollOffset: Scheduler.currentScrollPos.dx == 0 ? 
     Scheduler.currentScrollPos.dy : Scheduler.currentScrollPos.dx);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    //viewService.allDayRenderService = null;
    //viewService.primaryRenderService = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeSlots.clear();
    List<DateTime> dates = widget.date.incDates(widget.dayCount, (date, delta) => date.incDays(delta));
    bool todayInDates = dates.any((x) => x.isToday);
    double rowHeaderWidth = widget.rowHeaderWidth;
    int colCount = widget.colCount ?? widget.dayCount;
    int rowCount = widget.rowCount ?? 1;
    double height = widget.orientation == Axis.vertical ?
    widget.intervalCount * widget.intervalHeight : widget.height;

    double dayWidth = (widget.width - rowHeaderWidth) / colCount;
    double dayHeight = height / rowCount;

    double pixelsPerMinute = widget.orientation == Axis.vertical ?
        widget.intervalHeight / widget.interval :
    dayWidth / scheduler.schedulerSettings.dayDuration.inMinutes;

    Rect calendarRect = Rect.fromLTWH(
      rowHeaderWidth,
      0,
      widget.width - rowHeaderWidth,
      widget.height,
    );

    double activeDayLeft = 0;
    if (widget.showCurrentTimeIndicator && todayInDates) {
      activeDayLeft = min(calendarRect.width + rowHeaderWidth,
        rowHeaderWidth + (dayWidth * DateTime.now().startOfDay.diffInDays(widget.date.startOfDay)),
      );
    }

    var timeSlotTemplate = TimeSlot(
      widget.date,
      widget.date.incMinutes(widget.interval),
      widget.calendarViewType,
      widget.intervalType,
      widget.orientation == Axis.vertical ? widget.intervalHeight : widget.intervalWidth,
    );

    appointmentRenderService = AppointmentRenderService(
      pixelsPerMinute,
      widget.orientation == Axis.vertical ? AnchorPosition.top : AnchorPosition.left,
      timeSlotTemplate,
      calendarRect,
      dayWidth,
      widget.date,
      null,
      fixedSize: widget.fixedEventSize > 0,
    );

    if (widget.isAllDayHost) {
      viewService.allDayHostRenderService = appointmentRenderService;
    }
   
    if (widget.isAllDayGrid) {
      viewService.allDayRenderService = appointmentRenderService;
    }

    List<Widget>? renderAppointments() {
      dataSource.visibleDateRange.setRange(widget.date, widget.date.incDays(widget.dayCount, true));
      List<AppointmentItem> visibleItems = [];

      if (widget.eventLayoutHandler != null){
        Rect fullCalendarRect = Rect.fromLTWH(
           calendarRect.left,
           calendarRect.top,
           calendarRect.width,
           rowCount * widget.intervalHeight,
        );
        visibleItems = widget.eventLayoutHandler!(fullCalendarRect, appointmentRenderService!);
      } else {
        visibleItems = widget.getVisibleAppointments != null
         ? widget.getVisibleAppointments!.call()
         : dataSource.visibleAppointmentItemsByDay;
        for (int row = 0; row < rowCount; row++) {
          DateTime rowDate = widget.date.incDays(row * colCount);
          appointmentRenderService?.startDate = rowDate;
          for (int i = 0; i < colCount; i++) {
            DateTime date = rowDate.incDays(i);
            Rect dayRect = Rect.fromLTWH(
              rowHeaderWidth + (dayWidth * i), dayHeight * row, dayWidth,
              dayHeight,);
            appointmentRenderService?.measureAppointments(
              DateRange(date, date),
              dayRect,
              visibleItems,
            );
          }
        }
      }

      return appointmentRenderService?.renderAppointments(visibleItems);
    }

    return DragTarget(
      onAccept: (data) {
        //debugPrint(widget.intervalType.toString() + "  " + data.toString());
      },
      builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) =>
      Stack(
        children: [
          NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              if (schedulerService.scrollController == scrollController) {
                 var position = notification.metrics.pixels;
                 var positionOffset = notification.metrics.axis == Axis.vertical ? Offset(0, position) : Offset(position, 0);
                 scheduler.setSchedulerScrollPos(positionOffset);
              }
              return false;
            },
            child: widget.gridBuilder != null ? widget.gridBuilder!(context) : SchedulerGrid(
              gridHelper: widget.gridHelper,
              rowHeaderBuilder: widget.cellHeaderBuilder,
              columnHeaderBuilder: widget.columnHeaderBuilder,
              clientRect: calendarRect,
              headerPosition: widget.orientation == Axis.vertical ? HeaderPosition.columnStart : HeaderPosition.rowStart,
              orientation: widget.orientation,
              gridDates: dates,
              slotsPerTimeBlock: widget.slotsPerTimeBlock,
              cellSize: Size(dayWidth, widget.intervalHeight),
              intervalType: widget.intervalType,
              colCount: widget.colCount != null ? widget.colCount! : dates.length,
              rowCount: widget.rowCount != null ? widget.rowCount! : widget.intervalCount,
              scrollController: scrollController,
              showDashLines: widget.showDashLines,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: dataSource,
            builder: (BuildContext context, value, Widget? child) =>
                ScrollableStack(
                  scrollController: scrollController,
                  children: [...?renderAppointments()],
                ),
          ),
          if (widget.showCurrentTimeIndicator && todayInDates)
            CurrentTimeIndicator(
              startPos: rowHeaderWidth,
              activePos: activeDayLeft,
              activeLength: dayWidth,
              clientHeight: height,
              clientWidth: widget.width,
            ),
        ],
      ),
    );
  }

}
