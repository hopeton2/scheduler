part of scheduler;

class SchedulerDataSource extends ChangeNotifier
    implements ValueListenable<List<Appointment>> {
  late final List<Appointment> appointments;
  final RecurrenceService _recurrenceService = RecurrenceService.instance;

  SchedulerDataSource({List<Appointment>? appointments}) {
    this.appointments = appointments ?? <Appointment>[];
  }

  final DateRange _visibleDateRange = DateRange();
  DateRange get visibleDateRange {
    return _visibleDateRange;
  }

  setDateRange(DateTime start, DateTime end) {
    visibleDateRange.setRange(start, end);

    // Update AppointmentService's visible range when scheduler range changes
    AppointmentService.instance.visibleStart = start;
    AppointmentService.instance.visibleEnd = end;

    notifyListeners();
  }

  bool isAppointmentInDateRange(
      Appointment appointment, DateTime start, DateTime end) {
    // Check if the appointment overlaps with the date range:
    // 1. The appointment starts within the range
    // 2. The appointment ends within the range
    // 3. The appointment spans across the entire range
    return (appointment.startDate.isAfter(start) &&
            appointment.startDate.isBefore(end)) ||
        (appointment.endDate.isAfter(start) &&
            appointment.endDate.isBefore(end)) ||
        (appointment.startDate.isBefore(start) &&
            appointment.endDate.isAfter(end));
  }

  List<Appointment> getVisibleAppointments(DateTime start, DateTime end) {
    return appointments
        .where(
            (appointment) => isAppointmentInDateRange(appointment, start, end))
        .toList();
  }

  List<Appointment> get visibleAppointments {
    if (visibleDateRange.isEmpty) {
      return appointments;
    }

    return getVisibleAppointments(visibleDateRange.start, visibleDateRange.end);
  }

  // Get appointment items in a specific date range including recurrence
  List<AppointmentItem> getVisibleAppointmentItems(
      DateTime start, DateTime end) {
    final List<AppointmentItem> result = [];

    for (final appointment in appointments) {
      // Check if the appointment falls within the date range (even partially)
      if (isAppointmentInDateRange(appointment, start, end)) {
        // Add the normal appointment item
        result.add(AppointmentItem(
            appointment: appointment,
            startDate: appointment.startDate,
            endDate: appointment.endDate));
      }
    }

    // Add recurrence items separately using RecurrenceService
    result.addAll(_recurrenceService.getAllRecurrenceItemsInRange(
        appointments, start, end));

    return result;
  }

  List<AppointmentItem> get visibleAppointmentItems {
    if (visibleDateRange.isEmpty) {
      return _getAllAppointmentItems();
    }

    return getVisibleAppointmentItems(
        visibleDateRange.start, visibleDateRange.end);
  }

  // Get all appointment items including recurrence instances
  List<AppointmentItem> _getAllAppointmentItems() {
    final List<AppointmentItem> result = [];

    for (final appointment in appointments) {
      // Add regular appointment items
      result.add(AppointmentItem(
          appointment: appointment,
          startDate: appointment.startDate,
          endDate: appointment.endDate));

      // Add recurrence items if needed
      if (appointment.recurrenceRule != null &&
          appointment.recurrenceRule!.isNotEmpty) {
        result.addAll(_recurrenceService.generateRecurrenceItems(
            appointment,
            DateTime.now().subtract(const Duration(days: 365)),
            DateTime.now().add(const Duration(days: 365))));
      }
    }

    return result;
  }

  // Used by AppointmentRenderService to get appointments in a specific date range
  List<AppointmentItem> getAppointmentItemsInDateRange(
      DateTime startDate, DateTime endDate) {
    // Update the visible date range
    _updateVisibleDateRange(startDate, endDate);

    return getVisibleAppointmentItems(startDate, endDate);
  }

  void _updateVisibleDateRange(DateTime start, DateTime end) {
    _visibleDateRange.setRange(start, end);

    // Update AppointmentService's visible range
    AppointmentService.instance.visibleStart = start;
    AppointmentService.instance.visibleEnd = end;

    notifyListeners();
  }

  addAppointment(DateTime startDate, Duration duration, String subject,
      {Color color = const Color(0xff757575),
      isAllDay = false,
      String? recurrenceRule}) {
    Appointment appointment;
    if (isAllDay) {
      appointment = Appointment(startDate.toLocalTime.startOfDay,
          startDate.startOfDay.toLocalTime.add(duration).endOfDay, subject,
          color: color, isAllDay: isAllDay);
    } else {
      appointment = Appointment(
          startDate.toLocalTime, startDate.toLocalTime.add(duration), subject,
          color: color);
    }
    appointment.subject =
        "$subject ${appointment.startDate} - ${appointment.endDate}";
    appointments.add(appointment);
    notifyListeners();
  }

  addAllDayAppointment(DateTime startDate, String subject,
      {Color color = const Color(0xff757575), int days = 1}) {
    startDate = startDate.startOfDay;
    Duration duration = Duration(days: days - 1);
    addAppointment(startDate, duration, subject, color: color, isAllDay: true);
  }

  deleteAppointment(Appointment appointment) {
    appointments.remove(appointment);
    notifyListeners();
  }

  rescheduleAppointment(Appointment appointment, DateTime startDate,
      DateTime endDate, bool isAllDay) {
    if (appointment.isAllDay && isAllDay == false) {
      endDate =
          startDate.add(schedulerService.appointmentSettings.defaultDuration);
    }
    if (isAllDay) {
      startDate = startDate.startOfDay;
      endDate = endDate.endOfDay;
    }
    appointment.setDates(startDate, endDate);
    appointment.isAllDay = isAllDay;
    appointment.subject = "${appointment.startDate} - ${appointment.endDate}";
    notifyListeners();
  }

  updateListeners() {
    notifyListeners();
  }

  @override
  List<Appointment> get value => visibleAppointments;

  List<AppointmentItem> visibleAppointmentItemsByDateRange(
      DateTime first, DateTime last) {
    // Create a temporary date range for this specific query
    final tempRange = DateRange();
    tempRange.setRange(first, last);

    return getVisibleAppointmentItems(first, last);
  }

  // Modified to incorporate recurrence
  List<AppointmentItem> getVisibleAppointmentItemsFrom(
      AppointmentItemListFunction getItems) {
    final List<AppointmentItem> result = [];
    final DateTime start = visibleDateRange.start;
    final DateTime end = visibleDateRange.end;

    for (final appointment in appointments) {
      // Get standard items from the provided function
      final List<AppointmentItem> items = getItems(appointment);

      // Add those that fall within the date range
      for (final item in items) {
        if (item.startDate.isBefore(end) && item.endDate.isAfter(start)) {
          result.add(item);
        }
      }
    }

    // Add all recurrence items using RecurrenceService
    result.addAll(_recurrenceService.getAllRecurrenceItemsInRange(
        appointments, start, end));

    return result;
  }

  List<AppointmentItem> get visibleAppointmentItemsByDay {
    if (visibleDateRange.isEmpty) {
      return _getAllAppointmentItems();
    }

    return getVisibleAppointmentItemsFrom(
        (appointment) => appointment.appointmentItemsByDay);
  }

  List<AppointmentItem> get visibleAppointmentItemsByWeek {
    if (visibleDateRange.isEmpty) {
      return _getAllAppointmentItems();
    }

    return getVisibleAppointmentItemsFrom(
        (appointment) => appointment.appointmentItemsByWeek);
  }

  List<AppointmentItem> get visibleAppointmentItemsByMonth {
    if (visibleDateRange.isEmpty) {
      return _getAllAppointmentItems();
    }

    return getVisibleAppointmentItemsFrom(
        (appointment) => appointment.appointmentItemsByMonth);
  }
}
