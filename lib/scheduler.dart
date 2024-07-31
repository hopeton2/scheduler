library scheduler;

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dart_date/dart_date.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
//import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:scheduler/date_range.dart';
import 'package:scheduler/draggable_cursor.dart';
import 'package:scheduler/extensions/color_extensions.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/interval_config.dart';
import 'package:scheduler/models/appointment_item.dart';
import 'package:scheduler/services/appointment_drag_service.dart';
import 'package:scheduler/services/appointment_render_service.dart';
import 'package:scheduler/services/appointment_service.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/services/services.dart';
import 'package:scheduler/services/view_navigation_service.dart';
import 'package:scheduler/slot_selector.dart';
import 'package:scheduler/themes/month_view_theme.dart';
import 'package:scheduler/time_slot.dart';
import 'package:scheduler/views/scheduler_view.dart';
import 'package:scheduler/widgets/date_header.dart';
import 'package:scheduler/widgets/open_border.dart';
import 'package:scheduler/widgets/scrollable_stack.dart';
import 'package:scheduler/widgets/timeslot_cell.dart';
import 'package:uuid/uuid.dart';

import 'common/scheduler_view_helper.dart';
import 'constants.dart';
import 'scheduler_controller.dart';
import 'services/event_layout_manager.dart';
import 'services/ui_service.dart';
import 'themes/scheduler_theme.dart';
import 'views/day/allday_event_grid.dart';
import 'views/month/month_cell_header.dart';
import 'widgets/appointment/appointment_dragger.dart';
import 'widgets/appointment/appointment_resizer.dart';
import 'widgets/event_grid/event_grid.dart';
import 'widgets/scheduler_grid/cell_painter.dart';
import 'widgets/scheduler_grid/grid_cell.dart';
import 'widgets/scheduler_grid/grid_helper.dart';
import 'widgets/scheduler_grid/scheduler_grid.dart';
import 'widgets/scheduler_grid/timebar/timebar_cell.dart';
import 'widgets/virtual_page_view/virtual_page_view.dart';
import 'widgets/view_navigator/button_navigation.dart';
import 'widgets/view_navigator/popup_navigation_ex.dart';

part 'views/day/day_view.dart';
part 'views/week/week_view.dart';
part 'views/month/month_view.dart';
part 'views/timeline/timeline_view.dart';
part 'enums.dart';
part 'models/appointment.dart';
part 'scheduler_data_source.dart';
part 'widgets/appointment/appointment_widget.dart';
part 'settings/month_view_settings.dart';
part 'settings/day_view_settings.dart';
part 'settings/timeline_view_settings.dart';
part 'settings/scheduler_settings.dart';
part 'settings/appointment_settings.dart';
part 'widgets/view_navigator/view_navigator.dart';
part 'typedefs.dart';


class JzScheduler extends StatefulWidget {
  final SchedulerSettings schedulerSettings;
  final DayViewSettings dayViewSettings;
  final MonthViewSettings monthViewSettings;
  final TimelineViewSettings timelineViewSettings;
  final AppointmentSettings appointmentSettings;
  final SchedulerDataSource? dataSource;
  final ViewNavigator? viewNavigator;
  final CalendarViewType viewType;
  final SchedulerController? controller;
  final DateTime? initialDate;

  JzScheduler({
    Key? key,
    this.initialDate,
    this.controller,
    this.dataSource,
    this.viewNavigator,
    this.viewType = CalendarViewType.day,
    this.schedulerSettings = const SchedulerSettings(),
    this.dayViewSettings = const DayViewSettings(),
    this.monthViewSettings = const MonthViewSettings(),
    this.timelineViewSettings = const TimelineViewSettings(),
    this.appointmentSettings = const AppointmentSettings(),
  }):
    super( key: key,) {
    ViewNavigationService().viewType = viewType;
  }


  @override
  _SchedulerState createState() => _SchedulerState();

}

class _SchedulerState extends State<JzScheduler> with TickerProviderStateMixin {
  bool isAutoScale = false;
  late SchedulerController controller;
  late AnimationController viewAnimationController;
  
  @override
  void initState() {
    viewAnimationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    ViewNavigationService().viewChangeNotify.addListener(() {setState(()=>{});});
    controller = widget.controller != null ? widget.controller! : SchedulerController(date: widget.initialDate);
    controller.addListener(() {setState(()=>{});});
    super.initState();
  }

  @override
  void dispose(){
    widget.controller!.dispose();
    viewAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Scheduler scheduler = Scheduler(scheduler: widget,
        viewNavigator: widget.viewNavigator,
        controller: controller,
        viewAnimationController: viewAnimationController,
    );
    SchedulerService(scheduler: scheduler);
  /*  if (isAutoScale){
      return ResponsiveWrapper.builder(
        scheduler,
        minWidth: 450,
        defaultScale: true,
        breakpoints: [
          const ResponsiveBreakpoint.resize(450, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(800, name: TABLET),
          const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
          const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
        ],
      );
    }*/

    return scheduler;
  }


}


class Scheduler extends InheritedWidget {
  late final Timer _timer;
  final SlotSelector slotSelector = SlotSelector();
  // final DateRange dateRange = DateRange();
  final ValueNotifier<DateTime> clockTickNotify = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<Offset> schedulerScrollPosNotify = ValueNotifier<Offset>(Offset.zero);
  final ViewNavigator? viewNavigator;
  final SchedulerController controller;
  final AnimationController viewAnimationController;
  final String uuid;
  final JzScheduler scheduler;

  static Offset currentScrollPos = Offset.zero;

  Scheduler({Key? key, 
    required this.scheduler,
    this.viewNavigator, 
    required this.controller,
    required this.viewAnimationController,
  })
    : uuid = const Uuid().v4().toString(), super(key: key,
    child: Material(
      child: Column(
        children: [
          viewNavigator ?? const ViewNavigator(),
          Expanded(
            child: ViewNavigationService().currentView!,
          ),
        ],
      ),
    ),
  ){
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      clockTickNotify.value = DateTime.now();
    });
  }

  SchedulerSettings get schedulerSettings => scheduler.schedulerSettings;
  DayViewSettings get dayViewSettings => scheduler.dayViewSettings;
  MonthViewSettings get monthViewSettings => scheduler.monthViewSettings;
  TimelineViewSettings get timelineViewSettings => scheduler.timelineViewSettings;
  AppointmentSettings get appointmentSettings => scheduler.appointmentSettings;
  SchedulerDataSource? get dataSource => scheduler.dataSource;
  DateTime get startDate => controller.startDate;
  DateRange get dateRange => scheduler.dataSource!.visibleDateRange;
  CalendarViewType get viewType => ViewNavigationService().viewType;


  set viewType(CalendarViewType value) {
    ViewNavigationService().viewType = value;
  }

  void setSchedulerScrollPos(Offset value) {
    schedulerScrollPosNotify.value = value;
    currentScrollPos = value;
  }

  
  bool _positionInitialized = false;
  void initializeSchedulerScrollPos(Offset value) {
    if (!_positionInitialized) {
      _positionInitialized = true;
      setSchedulerScrollPos(value);
    }
  }

  static Scheduler of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Scheduler>()!;
  }

  @override
  bool updateShouldNotify(covariant Scheduler oldWidget) {
     return oldWidget.uuid != uuid;

  }

  void dispose() {
    _timer.cancel();
  }
}



/*
class Scheduler extends InheritedWidget {
  late final SchedulerSettings schedulerSettings;
  late final DayViewSettings dayViewSettings;
  late final MonthViewSettings monthViewSettings;
  late final TimelineViewSettings timelineViewSettings;
  late final AppointmentSettings appointmentSettings;
  final SlotSelector slotSelector = SlotSelector();
  final DateRange dateRange = DateRange();
  late final Timer _timer;
  final ValueNotifier<DateTime> clockTickNotify = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<double> schedulerScrollPosNotify = ValueNotifier<double>(0);
  final SchedulerDataSource? dataSource;
  final ViewNavigator? viewNavigator;
  late final DateTime? initialDate;

  Scheduler({
    Key? key,
    DateTime? initialDate,
    this.dataSource,
    this.viewNavigator,
    required viewType,
    SchedulerSettings? schedulerSettings,
    DayViewSettings? dayViewSettings,
    MonthViewSettings? monthViewSettings,
    TimelineViewSettings? timelineViewSettings,
    AppointmentSettings? appointmentSettings,
  }) : super(
          key: key,
          child: Material(
            child: Column(
              children: [
                viewNavigator ?? const ViewNavigator(),
                Expanded(
                  child: ViewNavigationService().currentView!,
                ),
              ],
            ),
          ),
        )
  {
    this.schedulerSettings = schedulerSettings ?? const SchedulerSettings();
    this.dayViewSettings = dayViewSettings ?? const DayViewSettings();
    this.monthViewSettings = monthViewSettings ?? const MonthViewSettings();
    this.timelineViewSettings = timelineViewSettings ?? const TimelineViewSettings();
    this.appointmentSettings = appointmentSettings ?? const AppointmentSettings();
    this.initialDate = initialDate ?? DateTime.now();
    SchedulerService(scheduler: this);

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      clockTickNotify.value = DateTime.now();
    });
  }

  set viewType(CalendarViewType value) {
    ViewNavigationService().viewType = value;
  }

  CalendarViewType get viewType => ViewNavigationService().viewType;

  void notifySchedulerScrollPos(double value) {
    schedulerScrollPosNotify.value = value;
  }

  static Scheduler? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Scheduler>();

  @override
  bool updateShouldNotify(covariant Scheduler oldWidget) {
    return true; // (oldWidget.schedulerSettings != schedulerSettings) || (oldWidget.slotSelector != slotSelector);
  }

  void dispose() {
    _timer.cancel();
  }
}
*/