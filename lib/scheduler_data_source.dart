part of scheduler;

class SchedulerDataSource extends ChangeNotifier implements ValueListenable<List<Appointment>> {

  late final List<Appointment> appointments;
  SchedulerDataSource({List<Appointment>? appointments}){
    this.appointments = appointments ?? <Appointment>[];
  }


  final DateRange _visibleDateRange = DateRange();
  DateRange get visibleDateRange {
     return _visibleDateRange;
  }

  setDateRange(DateTime start, DateTime end) {
    visibleDateRange.setRange(start, end);
    notifyListeners();
  }

  List<Appointment> get visibleAppointments {
    if (visibleDateRange.isEmpty) {
      return appointments;
    }

    /* return appointments.where((a) => visibleDateRange.inRange(a.startDate) ||
        visibleDateRange.inRange(a.endDate)).toList(); */

     return appointments.where((a) => visibleDateRange.inRangeOrBetween(a.startDate, a.endDate)).toList();
  }

  List<AppointmentItem> get visibleAppointmentItems {
    if (visibleDateRange.isEmpty){
      return visibleAppointments.fold<List<AppointmentItem>>([], (appointmentItems, appointment) {
        appointmentItems.addAll(appointment.appointmentItems);

        return appointmentItems;
      });
    }

    return visibleAppointments.fold<List<AppointmentItem>>([], (appointmentItems, appointment) {
      appointmentItems.addAll(appointment.appointmentItems.where((a) => visibleDateRange.inRange(a.startDate) ||
          visibleDateRange.inRange(a.endDate)));

      return appointmentItems;
    });
  }

  List<AppointmentItem> visibleAppointmentItemsByDateRange(DateTime first, DateTime last) {
    return getVisibleAppointmentItemsFrom((appointment) => appointmentService.getAppointmentItemsByDateRange(appointment, first, last));
  }

  List<AppointmentItem> get visibleAppointmentItemsByDay {
    return getVisibleAppointmentItemsFrom((appointment) => appointment.appointmentItemsByDay);
  }

  List<AppointmentItem> get visibleAppointmentItemsByWeek {
    var result = getVisibleAppointmentItemsFrom((appointment) => appointment.appointmentItemsByWeek);
    return result;
  }

  List<AppointmentItem> get visibleAppointmentItemsByMonth {
    return getVisibleAppointmentItemsFrom((appointment) => appointment.appointmentItemsByMonth);
  }

  List<AppointmentItem> getVisibleAppointmentItemsFrom(AppointmentItemListFunction getItems) {
    if (visibleDateRange.isEmpty){
      return visibleAppointments.fold<List<AppointmentItem>>([], (appointmentItems, appointment) {
        appointmentItems.addAll(getItems(appointment));

        return appointmentItems;
      });
    }

    return visibleAppointments.fold<List<AppointmentItem>>([], (appointmentItems, appointment) {
      appointmentItems.addAll(getItems(appointment).where((a) => visibleDateRange.inRange(a.startDate) ||
          visibleDateRange.inRange(a.endDate)));

      return appointmentItems;
    });
  }


  addAppointment(DateTime startDate, Duration duration, String subject, {Color color = const Color(0xff757575), isAllDay = false}){
    Appointment appointment;
    if (isAllDay){
      appointment = Appointment(startDate.toLocalTime.startOfDay, startDate.startOfDay.toLocalTime.add(duration).endOfDay, subject, color: color, isAllDay: isAllDay);

    }
    else {
      appointment = Appointment(startDate.toLocalTime, startDate.toLocalTime.add(duration), subject, color: color);
    }
    appointment.subject =  "$subject ${appointment.startDate} - ${appointment.endDate}";
    appointments.add(appointment);
    notifyListeners();
  }

  addAllDayAppointment(DateTime startDate, String subject, {Color color = const Color(0xff757575), int days = 1}){
    startDate = startDate.startOfDay;
    Duration duration = Duration(days: days-1);
    addAppointment(startDate, duration, subject, color: color, isAllDay: true);
  }

  deleteAppointment(Appointment appointment) {
    appointments.remove(appointment);
    notifyListeners();
  }

  rescheduleAppointment(Appointment appointment, DateTime startDate, DateTime endDate, bool isAllDay) {
    if (appointment.isAllDay && isAllDay == false){
      endDate = startDate.add(schedulerService.appointmentSettings.defaultDuration);
    }
    if (isAllDay){
      startDate = startDate.startOfDay;
      endDate = endDate.endOfDay;
    }
    appointment.setDates(startDate, endDate);
    appointment.isAllDay = isAllDay;
    appointment.subject =  "${appointment.startDate} - ${appointment.endDate}";
    notifyListeners();
  }

  updateListeners() {
    notifyListeners();
  }

  @override
  List<Appointment> get value => visibleAppointments;

}


