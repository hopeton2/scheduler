part of scheduler;

typedef AppointmentItemGenerator = List<AppointmentItem> Function(
  Appointment appointment,
  DateTime startDate,
  DateTime endDate,
);

class Appointment {
  String? id;
  late DateTime _startDate;
  DateTime get startDate => _startDate;

  late DateTime _endDate;
  DateTime get endDate => _endDate;

  final appointmentService = AppointmentService.instance;

  String? recurrenceRule;
  String subject;
  Color color;
  bool isAllDay;
  final List<AppointmentItem> appointmentItems = [];
  final List<AppointmentItem> appointmentItemsByDay = [];
  final List<AppointmentItem> appointmentItemsByWeek = [];
  final List<AppointmentItem> appointmentItemsByMonth = [];

  Appointment(
    DateTime startDate,
    DateTime endDate,
    this.subject, {
    this.id,
    this.color = Colors.grey,
    this.isAllDay = false,
    this.recurrenceRule,
  }) {
    setDates(startDate, endDate);
    id ??= const Uuid().v4();
  }

  Duration get duration {
    return endDate.difference(startDate);
  }

  setDates(DateTime start, DateTime end) {
    if (start.isBefore(end)) {
      _startDate = start;
      _endDate = end;
      _generateAppointmentItems();
    }
  }

  get shortSummary {
    final editorSettings =
        SchedulerService().scheduler.appointmentEditorSettings;
    return "${DateFormat(editorSettings.dateFormat).format(startDate)} to ${DateFormat(editorSettings.dateFormat).format(endDate)}";
  }

  get longSummary {
    final editorSettings =
        SchedulerService().scheduler.appointmentEditorSettings;
    return '$subject - ${DateFormat(editorSettings.dateTimeFormat).format(startDate)} - ${DateFormat(editorSettings.dateTimeFormat).format(endDate)}';
  }

  _generateAppointmentItems() {
    appointmentItems.clear();
    appointmentItemsByWeek.clear();
    appointmentItemsByMonth.clear();
    appointmentItemsByDay.clear();
    appointmentItems.addAll(appointmentService.getSingleAppointmentItems(this));
    appointmentItemsByDay
        .addAll(appointmentService.getAppointmentItemsByDay(this));
    appointmentItemsByWeek
        .addAll(appointmentService.getAppointmentItemsByWeek(this));
    appointmentItemsByMonth
        .addAll(appointmentService.getAppointmentItemsByMonth(this));
  }
}
