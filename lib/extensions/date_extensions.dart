import 'package:dart_date/dart_date.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

typedef IncDate = DateTime Function(DateTime date, int delta);

extension DateExtension on DateTime {
  bool get isTopOfHour {
    return minute == 0;
  }

  DateTime get startOfQuarter {
    return DateTime(year, (quarter - 1) * 3 + 1, 1);
  }

  DateTime get endOfQuarter {
    return startOfQuarter.addMonths(3).incDays(-1);
  }

  bool get isStartOfQuarter {
    return startOfQuarter == this;
  }

  bool get isEndOfQuarter {
    return endOfQuarter == this;
  }

  bool get isStartOfMonth {
    return startOfMonth == startOfDay;
  }

  bool get isStartOfWeek {
    return startOfWeek == this;
  }

  bool get isStartOfYear {
    return startOfYear == this;
  }

  bool get isStartOfDay {
    return startOfDay == this;
  }

  // bool get isToday {
  //   return startOfDay == DateTime.now().startOfDay;
  // }

  int get quarter {
    return (month + 2) ~/ 3;
  }

  double get totalMinutes {
    double result = hour * 60 + minute + second / 60;

    return result;
  }

  String get formatHour {
    return DateFormat(DateFormat.HOUR).format(this);
  }

  int get daysInMonth {
    switch (month) {
      case 1:
        return 31;
      case 2:
        return isLeapYear ? 29 : 28;
      case 3:
        return 31;
      case 4:
        return 30;
      case 5:
        return 31;
      case 6:
        return 30;
      case 7:
        return 31;
      case 8:
        return 31;
      case 9:
        return 30;
      case 10:
        return 31;
      case 11:
        return 30;
      case 12:
        return 31;
      default:
        return 0;
    }
  }

  int getDifferenceInCalendarDays(DateTime other) =>
      other.startOfDay.differenceInDays(startOfDay);
  int getDifferenceInCalendarWeeks(DateTime other) => other.getWeek - getWeek;
  int getDifferenceInCalendarMonths(DateTime other) =>
      other.getMonth - getMonth;

  DateTime getEndOfDay() {
    return startOfDay.addDays(1).subMilliseconds(1);
  }

  bool isBetween(DateTime start, DateTime end) {
    return this >= start && this <= end;
  }

  bool isInside(DateTime start, DateTime end) {
    return this > start && this < end;
  }

  bool isBetweenDay(DateTime start, DateTime end) {
    return startOfDay >= start.startOfDay && this <= end.startOfDay;
  }

  bool isSameWeek(DateTime other) => other.getWeek == getWeek;

  Duration duration(DateTime later) => Duration(
        days: later.differenceInDays(startOfDay),
        minutes: later.totalMinutes.toInt() - totalMinutes.toInt(),
      );

  DateTime closestMinute(int minuteInterval, {bool before = false}) {
    if (minute == 0) {
      return this;
    }
    if (minuteInterval == 0) {
      return before ? startOfHour : addMinutes(60 - minute);
    }
    List<DateTime> dates = [];
    DateTime date = startOfHour;
    while (date.isSameHour(startOfHour)) {
      dates.add(date);
      date = date.addMinutes(minuteInterval);
    }
    DateTime result = closestTo(dates)!;
    if (before && result.isAfter(this)) {
      result = result.addMinutes(-minuteInterval);
    }

    return result;
  }

  DateTime getStartOfWeek(int weekStartDay) {
    var date = toUtc();
    int isoWeekStartDay = date.startOfWeek.weekday;
    if (isoWeekStartDay == weekStartDay) {
      if (weekday == date.startOfWeek.weekday) {
        return this;
      }

      return date.startOfWeek;
    }

    return date.startOfWeek
        .incDays(weekStartDay); // getPreviousDay(weekStartDay);
  }

  DateTime getStartOfWorkWeeks(int weekStartDay, int workWeekStartDay) {
    var date = getStartOfWeek(weekStartDay);

    return date.getNextDay(workWeekStartDay);
  }

  DateTime getStartOfWorkWeek(int weekStartDay, int workWeekStartDay) {
    const int workDays = 5;
    // Find the previous startDayOfWeek
    DateTime startOfWeek = getStartOfWeek(weekStartDay);
    DateTime startOfWorkWeek = startOfWeek.getNextDay(workWeekStartDay);
    DateTime endOfWorkWeek = startOfWorkWeek.addDays(workDays);
    // If the previous startDayOfWeek is already in the workweek, subtract a week to get to the previous workweek
    if (endOfWorkWeek.isBefore(this)) {
      startOfWorkWeek = startOfWorkWeek.getNextDay(workWeekStartDay);
    }

    return startOfWorkWeek;
  }

  DateTime getNextDay(int day) {
    DateTime date = this;
    for (int i = 0; i < 7; i++) {
      date = date.incDays(i);
      if (date.getDay == day) {
        break;
      }
    }

    return date;
  }

  DateTime getPreviousDay(int dayNumber) {
    DateTime result = incDays(-1);
    while (result.weekday != dayNumber) {
      result = result.incDays(-1);
    }

    return result;
  }

  DateTime incDays(int delta, [bool endsSameDayOnLastDay = false]) {
    DateTime result = addDays(delta, true);
    if (endsSameDayOnLastDay) {
      result = result.subMilliseconds(1);
    }

    return result;
  }

  DateTime incMinutes(int delta) {
    //return addMinutes(delta, true);
    // return DateTime.utc(year, month, day, hour, minute + delta, second, millisecond, microsecond);
    // return addDuration(Duration(minutes: delta));
    var result = addMinutes(delta, true);
    var totMinutes = result.totalMinutes;
    var diff = totMinutes - totalMinutes;
    if (diff != delta) {
      result = DateTime.utc(year, month, day, hour, minute + delta, second,
          millisecond, microsecond);
    }

    return result;
  }

  int diffInDays(DateTime other) {
    var date1 = DateTime.utc(
        year, month, day, hour, minute, second, millisecond, microsecond);
    var date2 = DateTime.utc(other.year, other.month, other.day, other.hour,
        other.minute, other.second, other.millisecond, other.microsecond);
    var result = date1.differenceInDays(date2);

    return result;
  }

  Duration diffInDuration(DateTime other) {
    var date1 = DateTime.utc(
        year, month, day, hour, minute, second, millisecond, microsecond);
    var date2 = DateTime.utc(other.year, other.month, other.day, other.hour,
        other.minute, other.second, other.millisecond, other.microsecond);
    var result = date1.difference(date2);

    return result;
  }

  int diffInMonth(DateTime other) {
    var date1 = DateTime.utc(
        year, month, day, hour, minute, second, millisecond, microsecond);
    var date2 = DateTime.utc(other.year, other.month, other.day, other.hour,
        other.minute, other.second, other.millisecond, other.microsecond);
    var result = date1.difference(date2).inDays ~/ 30;

    return result;
  }

  DateTime addDuration(Duration duration) {
    DateTime result = add(duration);
    if (timeZoneOffset != result.timeZoneOffset) {
      result = result.add(timeZoneOffset - result.timeZoneOffset);
    }

    return result;
  }

  DateTime incWeeks(int delta) {
    return addWeeks(delta);
  }

  DateTime incMonths(int delta) {
    return addMonths(delta);
  }

  DateTime incYears(int delta) {
    return addYears(delta);
  }

  String responsiveDayName(
      String defaultFormat, BuildContext context, bool useDefault) {
    double clientWidth = MediaQuery.of(context).size.width;
    String format = defaultFormat;
    if (!useDefault) {
      if (clientWidth <= kSmallDevice) {
        format = "ccccc";
      } else if (clientWidth <= kMediumDevice) {
        format = "EEE";
      }
    }

    return DateFormat(format).format(this);
  }

  List<DateTime> incDates(int count, IncDate incDate) {
    List<DateTime> result = [];
    for (int i = 0; i < count; i++) {
      result.add(incDate(this, i));
    }

    return result;
  }
}

extension DateTimeHelpers on DateTime {
  /// Rounds the DateTime to the nearest duration (e.g., 15 minutes)
  DateTime roundToNearest(Duration duration) {
    final int millis = millisecondsSinceEpoch;
    final int durationInMillis = duration.inMilliseconds;
    return DateTime.fromMillisecondsSinceEpoch(
        ((millis + durationInMillis ~/ 2) ~/ durationInMillis) *
            durationInMillis);
  }
}
