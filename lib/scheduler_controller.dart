import 'package:flutter/foundation.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';

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
    if (_startDate != value) {
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
        : startDate = intervalConfigProxy.incrementPageDate(_startDate, multiplier: 1);
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
    if (viewType == CalendarViewType.month && visibleDateRange.dates.isNotEmpty && !date.isBetween(visibleDateRange.dates.first, visibleDateRange.dates.last)) {
      multiplier = date.isBefore(visibleDateRange.dates.first) 
      ? date.diffInMonth(visibleDateRange.dates.first) - 1
      : date.diffInMonth( visibleDateRange.dates.last) + 1;
    }
    startDate = intervalConfigProxy.incrementPageDate(incDate, multiplier: multiplier);
    selectDates([date]);
  }

  /// Update the start date but only invalidate the navigation view
  setNavDate(DateTime date) {
    _startDate = intervalConfigProxy.incrementPageDate(date, multiplier: 0);
    ViewNavigationService().invalidateNavigation();
    startDateChangeNotify.value = startDate;
  }

  selectDates(List<DateTime> dates) {
    _selectedDates.clear();
    _selectedDates.addAll(dates);
    selectedDatesChangeNotify.value = _selectedDates;
  }

  DateTime get selectedDate => selectedDates.isNotEmpty ? _selectedDates.first : startDate;
}

class IntervalConfigProxy with IntervalConfig {
  DateTime initializeViewDate(DateTime date) {
    return incrementPageDate(date, multiplier: 0);
  }
}
