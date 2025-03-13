import 'package:dart_date/dart_date.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/widgets/appointment/appointment_editor.dart';

import 'date_range.dart';
import 'interval_config.dart';
import 'services/scheduler_service.dart';
import 'services/services.dart';
import 'services/view_navigation_service.dart';

class SchedulerController extends ChangeNotifier {
  IntervalConfigProxy intervalConfigProxy = IntervalConfigProxy();

  Scheduler get scheduler => SchedulerService().scheduler;
  SchedulerSettings get schedulerSettings => scheduler.schedulerSettings;
  DateRange get visibleDateRange => scheduler.dateRange;

  final List<DateTime> _selectedDates = [DateTime.now()];
  List<DateTime> get selectedDates => _selectedDates;

  final ValueNotifier<DateTime> startDateChangeNotify =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<List<DateTime>> selectedDatesChangeNotify =
      ValueNotifier<List<DateTime>>([DateTime.now()]);

  SchedulerController({DateTime? date}) {
    if (date != null) {
      _startDate = intervalConfigProxy.initializeViewDate(date);
    }
    startDateChangeNotify.value = _startDate;
  }

  DateTime _startDate = DateTime.now();
  DateTime get startDate {
    DateTime result = _startDate;

    return result;
  }

  bool canSelectAndJumpToDayView = false;

  set startDate(DateTime value) {
    if (!_startDate.isSameOrEqual(value)) {
      _startDate = value;
      startDateChangeNotify.value = value;
      notifyListeners();
    }
  }

  CalendarViewType get viewType => ViewNavigationService().viewType;
  set viewType(CalendarViewType value) {
    if (value != viewType) {
      ViewNavigationService().viewType = value;
    }
  }

  gotoNextPage() {
    schedulerSettings.navigationScroll
        ? ViewNavigationService().scrollNextPage()
        : startDate =
            intervalConfigProxy.incrementPageDate(_startDate, multiplier: 1);
  }

  gotoPreviousPage() {
    schedulerSettings.navigationScroll
        ? ViewNavigationService().scrollPreviousPage()
        : startDate =
            intervalConfigProxy.incrementPageDate(_startDate, multiplier: -1);
  }

  selectToday() {
    selectDate(DateTime.now());
  }

  selectInOneDay(DateTime date) {
    if (!canSelectAndJumpToDayView || viewType == CalendarViewType.day) {
      return;
    }
    _startDate = date;
    viewNavigationService.viewType = CalendarViewType.day;
    selectDates([date]);
  }

  selectDate(DateTime date) {
    int multiplier = 0;
    DateTime incDate = viewType == CalendarViewType.month ? startDate : date;
    if (viewType == CalendarViewType.month &&
        visibleDateRange.dates.isNotEmpty &&
        !date.isBetween(
            visibleDateRange.dates.first, visibleDateRange.dates.last)) {
      multiplier = date.isBefore(visibleDateRange.dates.first)
          ? date.diffInMonth(visibleDateRange.dates.first) - 1
          : date.diffInMonth(visibleDateRange.dates.last) + 1;
    }
    startDate =
        intervalConfigProxy.incrementPageDate(incDate, multiplier: multiplier);
    selectDates([date]);
  }

  /// Update the start date but only invalidate the navigation view
  setNavDate(DateTime date) {
    _startDate = intervalConfigProxy.incrementPageDate(date, multiplier: 0);
    ViewNavigationService().invalidateNavigation();
    startDateChangeNotify.value = startDate;
  }

  selectDates(List<DateTime> dates) {
    if (dates.length == _selectedDates.length &&
        dates.every((date) => _selectedDates.any((selectedDate) => selectedDate.isSameOrEqual(date)))) {
      return;
    }
    _selectedDates.clear();
    _selectedDates.addAll(dates);
    selectedDatesChangeNotify.value = _selectedDates;
  }

  DateTime get selectedDate =>
      selectedDates.isNotEmpty ? _selectedDates.first : startDate;

  /// Creates a new appointment using the current date as reference
  void createNewAppointment(BuildContext context) {
    // Get the current selected date from controller
    final DateTime currentDate = selectedDate;

    // Get the current time for time component
    final DateTime now = DateTime.now();

    // Combine selected date with current time (rounded to nearest 15 minutes)
    DateTime startTime = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      now.hour,
      now.minute,
    ).roundToNearest(const Duration(minutes: 15));

    // If the calculated start time is in the past, set it to the next 15-minute interval
    if (startTime.isBefore(now)) {
      startTime = now.roundToNearest(const Duration(minutes: 15))
          .add(const Duration(minutes: 15));
    }

    // Set end time to 1 hour after start
    final DateTime endTime = startTime.add(const Duration(hours: 1));

    // Show the appointment editor dialog
    showDialog(
      context: context,
      builder: (context) => AppointmentEditor(
        initialStartDate: startTime,
        initialEndDate: endTime,
      ),
    );
  }
}

class IntervalConfigProxy with IntervalConfig {
  DateTime initializeViewDate(DateTime date) {
    return incrementPageDate(date, multiplier: 0);
  }
}
