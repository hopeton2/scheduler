// ignore_for_file: unused_import

import 'package:dart_date/dart_date.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/services/view_navigation_service.dart';

mixin IntervalConfig {
  IntervalMinute? intervalMinute;

  get viewType {
    return ViewNavigationService().viewType;
  }

  int getTimeBlockSize() {
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        return 60 ~/ intervalMinute!.value;
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
      case CalendarViewType.workWeek:
        return 1;
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return 1;
      case CalendarViewType.year:
        return 1;
      case CalendarViewType.quarter:
        return 1;
      default:
        return 1;
    }
  }

  bool get showIntervalHeadings =>
      isDayPeriod && intervalMinute != IntervalMinute.min60;
  bool get isDayPeriod =>
      viewType == CalendarViewType.day ||
      viewType == CalendarViewType.timelineDay;

  DateTime get startDate => getStartDate();

  DateTime getStartDate([DateTime? proposedDate]) {
    DateTime date = proposedDate ??
        SchedulerService().scheduler.controller.startDate.startOfDay;
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        return date.startOfDay;
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
        return date.getStartOfWeek(
          SchedulerService().schedulerSettings.firstDayOfWeek,
        );
      case CalendarViewType.timelineWorkWeek:
      case CalendarViewType.workWeek:
        return date.getStartOfWorkWeek(
          SchedulerService().schedulerSettings.firstDayOfWeek,
          SchedulerService().schedulerSettings.firstDayOfWorkWeek,
        );
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return date.startOfMonth;
      case CalendarViewType.year:
        return date.startOfYear;
      case CalendarViewType.quarter:
        return date.startOfQuarter;
      default:
        return date;
    }
  }

  bool showTimeBlockDivider(bool canShow, DateTime date) {
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        return canShow;
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
        return canShow && date.isStartOfWeek;
      case CalendarViewType.timelineWorkWeek:
      case CalendarViewType.workWeek:
        return canShow && date.isStartOfWeek;
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return canShow && date.isStartOfMonth;
      case CalendarViewType.year:
        return canShow && date.isStartOfYear;
      case CalendarViewType.quarter:
        return canShow && date.isStartOfQuarter;
      default:
        return canShow;
    }
  }

  String get periodHeaderFormat {
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        return 'EEEE, MMMM d, yyyy';
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
        return 'MMMM d, yyyy';
      case CalendarViewType.timelineWorkWeek:
      case CalendarViewType.workWeek:
        return 'MMMM d, yyyy';
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return 'MMMM, yyyy';
      case CalendarViewType.year:
        return 'yyyy';
      case CalendarViewType.quarter:
        return 'QQQ, yyyy';
      default:
        return '';
    }
  }

  String get timeBlockHeaderFormat {
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        return 'j';
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
        return 'EEE';
      case CalendarViewType.timelineWorkWeek:
      case CalendarViewType.workWeek:
        return 'EEE';
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return 'EEE d';
      case CalendarViewType.year:
        return 'MMM yyyy';
      case CalendarViewType.quarter:
        return 'MMMM yyyy';
      default:
        return '';
    }
  }

  String get intervalHeaderFormat {
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
        return 'mm';
      case CalendarViewType.timelineWorkWeek:
      case CalendarViewType.workWeek:
        return 'mm';
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return 'EEE d MMM';
      case CalendarViewType.year:
        return 'MMM';
      case CalendarViewType.quarter:
        return 'MMMM';
      default:
        return '';
    }
  }

  DateHeaderType get groupHeaderType {
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        return DateHeaderType.hour;
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
        return DateHeaderType.day;
      case CalendarViewType.timelineWorkWeek:
      case CalendarViewType.workWeek:
        return DateHeaderType.day;
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return DateHeaderType.day;
      case CalendarViewType.year:
      case CalendarViewType.quarter:
        return DateHeaderType.month;
      default:
        return DateHeaderType.hour;
    }
  }

  int getGroupsPerPage(DateTime date) {
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        return 24;
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
        return 7;
      case CalendarViewType.timelineWorkWeek:
        return 5;
      case CalendarViewType.workWeek:
        return 7;
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return date.daysInMonth;
      case CalendarViewType.year:
        return 12;
      case CalendarViewType.quarter:
        return 3;
      default:
        return 1;
    }
  }

  int getIntervalsPerPage(DateTime date) {
    var result = getGroupsPerPage(date) * getTimeBlockSize();

    return result;
  }

  DateTime incrementPageDate(DateTime date, {int multiplier = 1}) {
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        return date.incDays(multiplier);
      case CalendarViewType.timelineWeek:
      case CalendarViewType.week:
        return date.incDays(multiplier * 7);
      case CalendarViewType.timelineWorkWeek:
      case CalendarViewType.workWeek:
        return date.incDays(multiplier * 7);
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        return date.startOfMonth.addMonths(multiplier);
      case CalendarViewType.year:
        return date.incYears(multiplier);
      case CalendarViewType.quarter:
        return date.incMonths(multiplier * 3);
      default:
        return date.incDays(multiplier);
    }
  }

  DateTime incrementIntervalGroupDate(
    DateTime groupDate, {
    int multiplier = 1,
    bool isInterval = false, //--when true it is not treated as a group
  }) {
    DateTime result;
    switch (viewType) {
      case CalendarViewType.timelineDay:
      case CalendarViewType.day:
        result = groupDate.incMinutes(
          intervalMinute!.value * getTimeBlockSize() * multiplier,
        );
        if (isInterval) {
          result = groupDate.incMinutes(intervalMinute!.value * multiplier);
        }
        break;
      case CalendarViewType.timelineWeek:
      case CalendarViewType.timelineWorkWeek:
      case CalendarViewType.week:
      case CalendarViewType.workWeek:
        result = groupDate.startOfDay.incDays(multiplier);
        break;
      case CalendarViewType.timelineMonth:
      case CalendarViewType.month:
        result = groupDate.startOfDay.incDays(multiplier);
        break;
      case CalendarViewType.year:
        result = groupDate.startOfDay.incMonths(multiplier);
        break;
      case CalendarViewType.quarter:
        result = groupDate.startOfDay.incMonths(multiplier);
        break;
      default:
        result = groupDate.incMinutes(
          intervalMinute!.value * getTimeBlockSize() * multiplier,
        );
    }

    return result;
  }
}
