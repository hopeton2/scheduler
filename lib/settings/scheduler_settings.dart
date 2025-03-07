part of scheduler;

@immutable
class SchedulerSettings with Diagnosticable {
  final String locale; // 'es_MX'; // 'ja_JP'; // Intl.systemLocale;
  final int firstDayOfWeek;
  final int firstDayOfWorkWeek;
  final List<DateTime> blackoutDates;
  final bool showCurrentTimeIndicator;
  final TimeOfDay dayStartTime;
  final TimeOfDay dayEndTime;
  final TimeOfDay workDayStartTime;
  final TimeOfDay workDayEndTime;
  final double dividerLineWidth;
  final String fontFamily;
  final Color? timebarBackgroundColor;
  final Color? timebarFontColor;
  final Color? timebarMinuteFontColor;
  final Color? workHoursBackgroundColor;
  final Color? dateHighlightColor;
  final Color? headerBackgroundColor;
  final Color? headerFontColor;
  final Color? backgroundColor;
  final Color? selectionBackgroundColor;
  final Color? selectionFontColor;
  final Color? currentDateBackgroundColor;
  final Color? cellHoverBorderColor;
  final Color? currentDateFontColor;
  final Color? dividerLineColor;
  final Color? intervalLineColor;
  final Color? currentTimeIndicatorColor;
  final bool currentTimeIndicatorEarlierDays;
  final int currentTimeIndicatorAnimationSpeed;
  final bool snapToTimeSlot;
  final bool navigationScroll;
  final bool showFloatingAppointmentButton;

  const SchedulerSettings({
    this.locale = 'en_US',
    this.firstDayOfWeek = 7,
    this.firstDayOfWorkWeek = 1,
    this.blackoutDates = const <DateTime>[],
    this.showCurrentTimeIndicator = true,
    this.dayStartTime = const TimeOfDay(hour: 0, minute: 0),
    this.dayEndTime = const TimeOfDay(hour: 24, minute: 0),
    this.workDayStartTime = const TimeOfDay(hour: 9, minute: 0),
    this.workDayEndTime = const TimeOfDay(hour: 17, minute: 0),
    this.dividerLineWidth = 0.75,
    this.snapToTimeSlot = true,
    this.fontFamily = "Roboto",
    this.timebarBackgroundColor, // = const Color(0xff616161),
    this.timebarFontColor, // = const Color(0xffeeeeee),
    this.timebarMinuteFontColor, // = const Color(0xffbdbdbd),
    this.workHoursBackgroundColor = const Color(0xff757575),
    this.dateHighlightColor = const Color(0xffff9800),
    this.headerBackgroundColor, // = const Color(0xff424242),
    this.headerFontColor, // = const Color(0xffffffff),
    this.backgroundColor, //= const Color(0xffffffff),
    this.selectionBackgroundColor = const Color(0x90ACC5EE),
    this.selectionFontColor = const Color(0xff2196f3),
    this.cellHoverBorderColor, // const(0xffff9800),
    this.currentDateBackgroundColor, // = const Color(0xff0964ac),
    this.currentDateFontColor, // = const Color(0xff2196f3) ,
    this.dividerLineColor, // = const Color(0xffff9800),
    this.intervalLineColor, // = const Color(0xff9e9e9e),
    this.currentTimeIndicatorColor = const Color(0xfffc1302),
    this.currentTimeIndicatorEarlierDays = true,
    this.currentTimeIndicatorAnimationSpeed = 250,
    this.navigationScroll = true,
    this.showFloatingAppointmentButton = true,
  }) : assert(firstDayOfWeek >= 1 && firstDayOfWeek <= 7);

  Duration get dayDuration {
    int startMinutes =
        Duration(hours: dayStartTime.hour, minutes: dayStartTime.minute)
            .inMinutes;
    int endMinutes =
        Duration(hours: dayEndTime.hour, minutes: dayEndTime.minute).inMinutes;
    int minuteDiff = endMinutes - startMinutes;

    return Duration(hours: minuteDiff ~/ 60, minutes: minuteDiff.remainder(60));
  }

  Color getIntervalLineColor(BuildContext context) {
    return intervalLineColor ?? Theme.of(context).dividerColor.withOpacity(.25);
  }

  Color getDividerLineColor(BuildContext context) {
    return dividerLineColor ?? Theme.of(context).dividerColor.withOpacity(.25);
  }

  Color getCellHoverBorderColor(BuildContext context) {
    return cellHoverBorderColor ?? Theme.of(context).colorScheme.primary;
  }

  Color getBackgroundColor(BuildContext context) {
    return backgroundColor ??
        Theme.of(context).extension<SchedulerTheme>()?.backgroundColor ??
        Theme.of(context).colorScheme.background;
  }

  getTimebarFontColor(BuildContext context) {
    return timebarFontColor ?? Theme.of(context).colorScheme.onBackground;
  }

  Color? getBackgroundFontColor(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }
}
