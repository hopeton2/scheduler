import 'package:flutter/material.dart';
import 'package:scheduler/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/models/appointment_item.dart';

class RecurrenceService {
  static final RecurrenceService _instance = RecurrenceService._internal();

  factory RecurrenceService() {
    return _instance;
  }

  RecurrenceService._internal();

  static RecurrenceService get instance => _instance;

  /// Generate AppointmentItems for a recurring appointment within a date range
  List<AppointmentItem> generateRecurrenceItems(
      Appointment appointment, DateTime start, DateTime end) {
    final List<AppointmentItem> items = [];

    // Skip if not a recurring appointment
    if (appointment.recurrenceRule == null ||
        appointment.recurrenceRule!.isEmpty) {
      return items;
    }

    final String rrule = appointment.recurrenceRule!;

    if (!rrule.startsWith('RRULE:')) {
      // Invalid recurrence rule
      return items;
    }

    // Parse recurrence rule
    final RecurrenceDetails details =
        _parseRecurrenceRule(rrule, appointment.startDate);
    if (details.frequency == null) {
      return items;
    }

    // Generate occurrences based on the recurrence pattern
    DateTime current = appointment.startDate;
    int occurrenceCount = 0;

    while (true) {
      // Check if we've reached the end conditions
      if (details.count != null && occurrenceCount >= details.count!) break;
      if (details.until != null && current.isAfter(details.until!)) break;
      if (current.isAfter(end)) break;

      // Only add occurrences in the visible range
      if (!current.isBefore(start)) {
        // Skip the first occurrence to avoid duplications with the base appointment
        // First occurrence is handled by regular appointment logic elsewhere
        if (occurrenceCount > 0) {
          // Calculate end time for this occurrence
          final Duration duration =
              appointment.endDate.difference(appointment.startDate);
          final DateTime occurrenceEnd = current.add(duration);

          // Create an AppointmentItem for this occurrence
          final AppointmentItem item = AppointmentItem(
            appointment: appointment,
            startDate: current,
            endDate: occurrenceEnd,
            isRecurrence: true,
          );

          items.add(item);
        }
      }

      // Count this occurrence
      occurrenceCount++;

      // Calculate the next occurrence
      current = _calculateNextOccurrence(current, details);
    }

    return items;
  }

  /// Get all recurrence items for all appointments within a date range
  List<AppointmentItem> getAllRecurrenceItemsInRange(
      List<Appointment> appointments, DateTime start, DateTime end) {
    final List<AppointmentItem> result = [];

    for (final appointment in appointments) {
      if (appointment.recurrenceRule != null &&
          appointment.recurrenceRule!.isNotEmpty) {
        result.addAll(generateRecurrenceItems(appointment, start, end));
      }
    }

    return result;
  }

  /// Check if an appointment has a recurrence rule
  bool hasRecurrence(Appointment appointment) {
    return appointment.recurrenceRule != null &&
        appointment.recurrenceRule!.isNotEmpty;
  }

  /// Build a recurrence rule based on provided parameters
  String buildRecurrenceRule({
    required RecurrenceType type,
    int interval = 1,
    int? count,
    DateTime? until,
    List<int>? weekDays,
    int? monthDay,
  }) {
    if (type == RecurrenceType.none) {
      return '';
    }

    final buffer = StringBuffer('RRULE:FREQ=');

    // Add frequency
    switch (type) {
      case RecurrenceType.daily:
        buffer.write('DAILY');
        break;
      case RecurrenceType.weekly:
        buffer.write('WEEKLY');
        if (weekDays != null && weekDays.isNotEmpty) {
          buffer.write(';BYDAY=');
          final days = weekDays.map((day) {
            switch (day) {
              case 1:
                return 'MO';
              case 2:
                return 'TU';
              case 3:
                return 'WE';
              case 4:
                return 'TH';
              case 5:
                return 'FR';
              case 6:
                return 'SA';
              case 7:
                return 'SU';
              default:
                return '';
            }
          }).join(',');
          buffer.write(days);
        }
        break;
      case RecurrenceType.monthly:
        buffer.write('MONTHLY');
        if (monthDay != null) {
          buffer.write(';BYMONTHDAY=${monthDay}');
        }
        break;
      case RecurrenceType.yearly:
        buffer.write('YEARLY');
        break;
      default:
        return '';
    }

    // Add interval if more than 1
    if (interval > 1) {
      buffer.write(';INTERVAL=$interval');
    }

    // Add end condition
    if (count != null) {
      buffer.write(';COUNT=$count');
    } else if (until != null) {
      final untilFormatted =
          DateFormat('yyyyMMdd\'T\'HHmmss\'Z\'').format(until);
      buffer.write(';UNTIL=$untilFormatted');
    }

    return buffer.toString();
  }

  /// Parse a recurrence rule string and return structured details
  RecurrenceParseResult parseRecurrenceRule(String rule) {
    RecurrenceType type = RecurrenceType.none;
    int interval = 1;
    int? count;
    DateTime? until;
    List<int>? weekDays;
    int? monthDay;

    if (!rule.startsWith('RRULE:')) {
      return RecurrenceParseResult(type: RecurrenceType.none);
    }

    // Extract frequency
    if (rule.contains('FREQ=')) {
      final String freqString = rule.split('FREQ=')[1].split(';')[0];
      switch (freqString) {
        case 'DAILY':
          type = RecurrenceType.daily;
          break;
        case 'WEEKLY':
          type = RecurrenceType.weekly;
          break;
        case 'MONTHLY':
          type = RecurrenceType.monthly;
          break;
        case 'YEARLY':
          type = RecurrenceType.yearly;
          break;
      }
    }

    // Extract interval
    final RegExp intervalRegex = RegExp(r'INTERVAL=(\d+)');
    final Match? intervalMatch = intervalRegex.firstMatch(rule);
    if (intervalMatch != null) {
      interval = int.parse(intervalMatch.group(1)!);
    }

    // Extract count
    final RegExp countRegex = RegExp(r'COUNT=(\d+)');
    final Match? countMatch = countRegex.firstMatch(rule);
    if (countMatch != null) {
      count = int.parse(countMatch.group(1)!);
    }

    // Extract until
    final RegExp untilRegex = RegExp(r'UNTIL=(\d{8}T\d{6}Z)');
    final Match? untilMatch = untilRegex.firstMatch(rule);
    if (untilMatch != null) {
      final String untilStr = untilMatch.group(1)!;
      final int year = int.parse(untilStr.substring(0, 4));
      final int month = int.parse(untilStr.substring(4, 6));
      final int day = int.parse(untilStr.substring(6, 8));
      until = DateTime(year, month, day);
    }

    // Extract weekdays for weekly recurrences
    if (type == RecurrenceType.weekly) {
      weekDays = [];
      final RegExp bydayRegex = RegExp(r'BYDAY=([^;]+)');
      final Match? bydayMatch = bydayRegex.firstMatch(rule);
      if (bydayMatch != null) {
        final String bydayStr = bydayMatch.group(1)!;
        if (bydayStr.contains('MO')) weekDays.add(1);
        if (bydayStr.contains('TU')) weekDays.add(2);
        if (bydayStr.contains('WE')) weekDays.add(3);
        if (bydayStr.contains('TH')) weekDays.add(4);
        if (bydayStr.contains('FR')) weekDays.add(5);
        if (bydayStr.contains('SA')) weekDays.add(6);
        if (bydayStr.contains('SU')) weekDays.add(7);
      }
    }

    // Extract day of month for monthly recurrences
    if (type == RecurrenceType.monthly) {
      final RegExp bymonthdayRegex = RegExp(r'BYMONTHDAY=(\d+)');
      final Match? bymonthdayMatch = bymonthdayRegex.firstMatch(rule);
      if (bymonthdayMatch != null) {
        monthDay = int.parse(bymonthdayMatch.group(1)!);
      }
    }

    return RecurrenceParseResult(
      type: type,
      interval: interval,
      count: count,
      until: until,
      weekDays: weekDays,
      monthDay: monthDay,
    );
  }

  /// Parse recurrence rule and extract recurrence details
  RecurrenceDetails _parseRecurrenceRule(String rule, DateTime baseDate) {
    RecurrenceType? frequency;
    int interval = 1;
    int? count;
    DateTime? until;
    List<int>? weekDays;
    int? monthDay;

    // Extract frequency
    if (rule.contains('FREQ=')) {
      final String freqString = rule.split('FREQ=')[1].split(';')[0];
      switch (freqString) {
        case 'DAILY':
          frequency = RecurrenceType.daily;
          break;
        case 'WEEKLY':
          frequency = RecurrenceType.weekly;
          break;
        case 'MONTHLY':
          frequency = RecurrenceType.monthly;
          break;
        case 'YEARLY':
          frequency = RecurrenceType.yearly;
          break;
      }
    }

    // Extract interval
    final RegExp intervalRegex = RegExp(r'INTERVAL=(\d+)');
    final Match? intervalMatch = intervalRegex.firstMatch(rule);
    if (intervalMatch != null) {
      interval = int.parse(intervalMatch.group(1)!);
    }

    // Extract count
    final RegExp countRegex = RegExp(r'COUNT=(\d+)');
    final Match? countMatch = countRegex.firstMatch(rule);
    if (countMatch != null) {
      count = int.parse(countMatch.group(1)!);
    }

    // Extract until
    final RegExp untilRegex = RegExp(r'UNTIL=(\d{8}T\d{6}Z)');
    final Match? untilMatch = untilRegex.firstMatch(rule);
    if (untilMatch != null) {
      final String untilStr = untilMatch.group(1)!;
      final int year = int.parse(untilStr.substring(0, 4));
      final int month = int.parse(untilStr.substring(4, 6));
      final int day = int.parse(untilStr.substring(6, 8));
      until = DateTime(year, month, day);
    }

    // Extract weekdays for weekly recurrences
    if (frequency == RecurrenceType.weekly) {
      weekDays = [];
      final RegExp bydayRegex = RegExp(r'BYDAY=([^;]+)');
      final Match? bydayMatch = bydayRegex.firstMatch(rule);
      if (bydayMatch != null) {
        final String bydayStr = bydayMatch.group(1)!;
        if (bydayStr.contains('MO')) weekDays.add(DateTime.monday);
        if (bydayStr.contains('TU')) weekDays.add(DateTime.tuesday);
        if (bydayStr.contains('WE')) weekDays.add(DateTime.wednesday);
        if (bydayStr.contains('TH')) weekDays.add(DateTime.thursday);
        if (bydayStr.contains('FR')) weekDays.add(DateTime.friday);
        if (bydayStr.contains('SA')) weekDays.add(DateTime.saturday);
        if (bydayStr.contains('SU')) weekDays.add(DateTime.sunday);
      } else {
        // If no BYDAY specified, use the day of the week from the original appointment
        weekDays.add(baseDate.weekday);
      }
    }

    // Extract day of month for monthly recurrences
    if (frequency == RecurrenceType.monthly) {
      final RegExp bymonthdayRegex = RegExp(r'BYMONTHDAY=(\d+)');
      final Match? bymonthdayMatch = bymonthdayRegex.firstMatch(rule);
      if (bymonthdayMatch != null) {
        monthDay = int.parse(bymonthdayMatch.group(1)!);
      } else {
        // If no BYMONTHDAY specified, use the day from the original appointment
        monthDay = baseDate.day;
      }
    }

    return RecurrenceDetails(
      frequency: frequency,
      interval: interval,
      count: count,
      until: until,
      weekDays: weekDays,
      monthDay: monthDay,
    );
  }

  /// Calculate the next occurrence based on recurrence details
  DateTime _calculateNextOccurrence(
      DateTime current, RecurrenceDetails details) {
    switch (details.frequency!) {
      case RecurrenceType.daily:
        return current.add(Duration(days: details.interval));

      case RecurrenceType.weekly:
        if (details.weekDays != null && details.weekDays!.isNotEmpty) {
          // Find the next day in the weekdays list
          int currentWeekday = current.weekday;
          int daysToAdd = 1;

          // Sort weekdays for easier next-day calculation
          details.weekDays!.sort();

          // Find the next weekday in the list
          bool found = false;
          for (final int weekday in details.weekDays!) {
            if (weekday > currentWeekday) {
              daysToAdd = weekday - currentWeekday;
              found = true;
              break;
            }
          }

          // If we didn't find a later day this week, move to the first day next week
          if (!found) {
            daysToAdd = 7 - currentWeekday + details.weekDays!.first;

            // If we're moving to the next week and there's an interval, adjust for that
            if (details.interval > 1 &&
                current.weekday >= details.weekDays!.last) {
              daysToAdd += 7 * (details.interval - 1);
            }
          }

          return current.add(Duration(days: daysToAdd));
        } else {
          // No specific weekdays, just add 7 * interval
          return current.add(Duration(days: 7 * details.interval));
        }

      case RecurrenceType.monthly:
        // Try to add the specified day to the next month
        final int year =
            current.year + ((current.month + details.interval - 1) ~/ 12);
        final int month = ((current.month + details.interval - 1) % 12) + 1;

        // Use the specified monthDay, or fall back to the original day
        int day = details.monthDay ?? current.day;

        // Check if the day is valid for the target month
        final int daysInMonth = DateTime(year, month + 1, 0).day;
        if (day > daysInMonth) {
          day =
              daysInMonth; // Use the last day of the month if the day is invalid
        }

        return DateTime(
            year, month, day, current.hour, current.minute, current.second);

      case RecurrenceType.yearly:
        // Add years based on interval
        return DateTime(
          current.year + details.interval,
          current.month,
          current.day,
          current.hour,
          current.minute,
          current.second,
        );

      default:
        // Default: add one day
        return current.add(const Duration(days: 1));
    }
  }
}

/// Class to hold parsed recurrence details
class RecurrenceDetails {
  final RecurrenceType? frequency;
  final int interval;
  final int? count;
  final DateTime? until;
  final List<int>? weekDays;
  final int? monthDay;

  RecurrenceDetails({
    this.frequency,
    this.interval = 1,
    this.count,
    this.until,
    this.weekDays,
    this.monthDay,
  });
}

/// Class to hold parsed recurrence rule information for UI usage
class RecurrenceParseResult {
  final RecurrenceType type;
  final int interval;
  final int? count;
  final DateTime? until;
  final List<int>? weekDays;
  final int? monthDay;
  final bool hasEnd;

  RecurrenceParseResult({
    required this.type,
    this.interval = 1,
    this.count,
    this.until,
    this.weekDays,
    this.monthDay,
  }) : hasEnd = (count != null || until != null);
}
