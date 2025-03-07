import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:scheduler/scheduler.dart';

class SchedulerService {
  static final SchedulerService instance = SchedulerService._internal();
  Scheduler? _scheduler;
  factory SchedulerService({Scheduler? scheduler}) {
    if (scheduler != null) {
      instance._scheduler = scheduler;
    }

    return instance;
  }
  SchedulerService._internal();

  Scheduler get scheduler => _scheduler!;
  SchedulerSettings get schedulerSettings =>
      scheduler.scheduler.schedulerSettings;
  DayViewSettings get dayViewSettings => scheduler.scheduler.dayViewSettings;
  MonthViewSettings get monthViewSettings =>
      scheduler.scheduler.monthViewSettings;
  TimelineViewSettings get timelineViewSettings =>
      scheduler.scheduler.timelineViewSettings;
  AppointmentSettings get appointmentSettings =>
      scheduler.scheduler.appointmentSettings;
  BuildContext? currentContext;
  ScrollController? scrollController;

  void createNewAppointment(BuildContext context) {
    scheduler.controller.createNewAppointment(context);
  }

  scrollScheduler(double scrollBy) {
    if (scrollController != null && scrollController!.positions.isNotEmpty) {
      scrollController!.jumpTo(max(0, scrollController!.offset + scrollBy));
    }
  }
}
