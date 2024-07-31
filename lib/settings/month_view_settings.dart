part of scheduler;

@immutable
class MonthViewSettings with Diagnosticable {
  final bool showWeekNumber;
  final String weekNumberCaption;
  final bool rotateWeekNumber;
  final double weekNumberWidth;
  final bool showLeadingAndTrailingDates;
  final TextStyle? leadingDaysTextStyle;
  final TextStyle? trailingDaysTextStyle;
  final Color? leadingDaysBackgroundColor;
  final Color? trailingDaysBackgroundColor;
  final String headerDayNameFormat;
  final String headerStyleName;
  final double dayMinHeight;
  final int fixedWeekCount;

  const MonthViewSettings({
    this.fixedWeekCount = 6,
    this.showWeekNumber = true,
    this.weekNumberCaption = 'Week',
    this.rotateWeekNumber = true,
    this.weekNumberWidth = 20,
    this.showLeadingAndTrailingDates = true,
    this.leadingDaysBackgroundColor, // = const Color(0xfff3f3f3),
    this.trailingDaysBackgroundColor, // = const Color(0xfff3f3f3),
    this.leadingDaysTextStyle, // = const TextStyle(color: Color(0xff000000)),
    this.trailingDaysTextStyle, // = const TextStyle(color: Color(0xff000000)),
    this.headerDayNameFormat = DateFormat.WEEKDAY,
    this.headerStyleName = 'monthStyle1',
    this.dayMinHeight = 100,
  });

  calcHeaderFormat(double clientWidth) {
    if (clientWidth <= kSmallDevice) {
      return "ccccc";
    } else if (clientWidth <= kMediumDevice) {
      return "EEE";
    }

    return headerDayNameFormat;
  }
}