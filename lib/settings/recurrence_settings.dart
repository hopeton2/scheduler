import 'package:flutter/material.dart';

/// Settings class for customizing recurrence-related strings and behaviors
class RecurrenceSettings {
  /// Label for the recurrence section toggle
  final String recurrenceLabel;

  /// Label for no recurrence option
  final String noRecurrenceLabel;

  /// Label for daily recurrence option
  final String dailyLabel;

  /// Label for weekly recurrence option
  final String weeklyLabel;

  /// Label for monthly recurrence option
  final String monthlyLabel;

  /// Label for yearly recurrence option
  final String yearlyLabel;

  /// Label for 'day' interval (singular)
  final String dayLabel;

  /// Label for 'days' interval (plural)
  final String daysLabel;

  /// Label for 'week' interval (singular)
  final String weekLabel;

  /// Label for 'weeks' interval (plural)
  final String weeksLabel;

  /// Label for 'month' interval (singular)
  final String monthLabel;

  /// Label for 'months' interval (plural)
  final String monthsLabel;

  /// Label for 'year' interval (singular)
  final String yearLabel;

  /// Label for 'years' interval (plural)
  final String yearsLabel;

  /// Label for day of month selector
  final String dayOfMonthLabel;

  /// Label for recurrence end options section
  final String endsLabel;

  /// Label for 'never ends' option
  final String neverLabel;

  /// Label for 'end after/on' option
  final String endAfterOnLabel;

  /// Label for occurrences counter
  final String occurrencesLabel;

  /// Label for end date selector
  final String endDateLabel;

  /// Label for weekly recurrence days
  final String repeatOnLabel;

  /// Label for interval input
  final String everyLabel;

  /// Label for recurrence pattern dropdown
  final String repeatLabel;

  /// Labels for days of the week (short form)
  final List<String> weekdayShortLabels;

  /// Title for edit recurrence dialog
  final String editRecurrenceTitle;

  /// Message for edit recurrence dialog
  final String editRecurrenceMessage;

  /// Label for cancel button
  final String cancelLabel;

  /// Label for this occurrence button
  final String thisOccurrenceLabel;

  /// Label for entire series button
  final String entireSeriesLabel;

  /// Title for delete recurrence dialog
  final String deleteRecurrenceTitle;

  /// Message for delete recurrence dialog
  final String deleteRecurrenceMessage;

  /// Message for unimplemented occurrence deletion
  final String deleteOccurrenceUnimplementedMessage;

  /// Label for select date hint
  final String selectDateLabel;

  const RecurrenceSettings({
    this.recurrenceLabel = 'Recurrence',
    this.noRecurrenceLabel = 'No Recurrence',
    this.dailyLabel = 'Daily',
    this.weeklyLabel = 'Weekly',
    this.monthlyLabel = 'Monthly',
    this.yearlyLabel = 'Yearly',
    this.dayLabel = 'day',
    this.daysLabel = 'days',
    this.weekLabel = 'week',
    this.weeksLabel = 'weeks',
    this.monthLabel = 'month',
    this.monthsLabel = 'months',
    this.yearLabel = 'year',
    this.yearsLabel = 'years',
    this.dayOfMonthLabel = 'Day of month:',
    this.endsLabel = 'Ends:',
    this.neverLabel = 'Never',
    this.endAfterOnLabel = 'End after/on',
    this.occurrencesLabel = 'Occurrences',
    this.endDateLabel = 'End date',
    this.repeatOnLabel = 'Repeat on:',
    this.everyLabel = 'Every',
    this.repeatLabel = 'Repeat',
    this.weekdayShortLabels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.editRecurrenceTitle = 'Edit Recurring Appointment',
    this.editRecurrenceMessage =
        'Would you like to edit this occurrence or the entire series?',
    this.cancelLabel = 'CANCEL',
    this.thisOccurrenceLabel = 'THIS OCCURRENCE',
    this.entireSeriesLabel = 'ENTIRE SERIES',
    this.deleteRecurrenceTitle = 'Delete Recurring Appointment',
    this.deleteRecurrenceMessage =
        'Would you like to delete just this occurrence or the entire series?',
    this.deleteOccurrenceUnimplementedMessage =
        'Deleting a single occurrence of a recurring appointment is not implemented yet',
    this.selectDateLabel = 'Select date',
  });
}
