part of scheduler;

typedef AppointmentItemListFunction = List<AppointmentItem> Function(Appointment appointment);
typedef SchedulerGridBuilder = Widget Function(BuildContext context, List<DateTime> dates);
typedef HeaderBuilder = Widget Function(BuildContext context, DateTime date, int index);
typedef PainterBuilder = CustomPainter? Function(BuildContext context);
typedef DateIncrementer = DateTime Function(DateTime date, int index);
typedef EventLayoutHandler = List<AppointmentItem> Function(Rect calendarRect, AppointmentRenderService appointmentRenderService);