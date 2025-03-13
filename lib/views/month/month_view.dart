part of scheduler;

class MonthView extends StatefulWidget {
  const MonthView({Key? key}) : super(key: key);

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> with IntervalConfig {
  Scheduler scheduler = SchedulerService.instance.scheduler;
  late SchedulerSettings schedulerSettings;
  late MonthViewSettings settings;
  late double weekNumberWidth = 0;
  late double dayWidth;
  late double daysWidth;
  late GridHelper gridHelper;
  late DateTime pageDate = startDate;
  late Color? backgroundColor;

  int get currentMonth => pageDate.incWeeks(1).month;

  @override
  void initState() {
    schedulerSettings = scheduler.schedulerSettings;
    settings = scheduler.monthViewSettings;
    schedulerService.scheduler.setSchedulerScrollPos(Offset.zero);
    gridHelper = GridHelper(
      incrementRowDate: (int rowIndex) => pageDate.startOfDay.addDays(
        rowIndex * DateTime.daysPerWeek,
        true,
      ),
      showCellDate: true,
      cellHeaderBuilder: (BuildContext context) => buildCellDateHeader(context),
    );
    super.initState();
  }

 ({DateTime start, DateTime end}) incCellDates(DateTime date, int index) {
    DateTime start = date.incDays(index).startOfDay;
    DateTime end = start.endOfDay;
    return (start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    // ColorScheme colorScheme = Theme.of(context).extension<MonthViewTheme>()?.colorScheme ?? Theme.of(context).colorScheme;
    backgroundColor =
        Theme.of(context).extension<MonthViewTheme>()?.backgroundColor ??
            schedulerSettings.getBackgroundColor(context);

    return SchedulerView(
      viewBuilder: buildView,
      backgroundColor: backgroundColor,
    );
  }

  Widget buildView(_, BoxConstraints constraints) {
    weekNumberWidth = settings.showWeekNumber ? settings.weekNumberWidth : 0;
    daysWidth = constraints.maxWidth - weekNumberWidth;
    dayWidth = daysWidth / DateTime.daysPerWeek;

    return VirtualPageView(
      key: GlobalKey(),
      initialDate: incrementPageDate(scheduler.controller.selectedDate, multiplier: 0),
      itemBuilder: (BuildContext context, date, _) {
        pageDate = date.startOfWeek;

        return Column(
          children: [
            buildMonthHeader(context),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  int colCount = 7;
                  int rowCount = 6;
                  int dayCount = colCount * rowCount;
                  double dayHeight = max(
                    settings.dayMinHeight,
                    constraints.maxHeight / rowCount,
                  );

                  return Container(
                    color: backgroundColor,
                    child: EventGrid(
                      gridHelper: gridHelper,
                      eventLayoutHandler: (Rect rect, AppointmentRenderService renderService) => EventLayoutManager(
                        renderService: renderService,
                        gridHelper: gridHelper,
                        initialDate: pageDate,
                        incCellDate: (DateTime date, int index) => incCellDates(date, index),
                        colCount: colCount,
                        rowCount: rowCount,
                        calendarRect: rect,
                        orientation: Axis.horizontal,
                        events: scheduler.dataSource!.visibleAppointmentItemsByWeek,
                        fixedSize: 18,
                      ).arrangeEvents(),
                      cellHeaderBuilder: (BuildContext context, DateTime date, _,) => buildWeekNumber(context, date, dayHeight),
                      showDashLines: false,
                      date: pageDate,
                      dayCount: dayCount,
                      rowCount: rowCount,
                      colCount: colCount,
                      constraints: constraints,
                      intervalHeight: dayHeight,
                      intervalWidth: dayWidth,
                      showCurrentTimeIndicator: false,
                      orientation: Axis.horizontal,
                      intervalType: IntervalType.day,
                      rowHeaderWidth: weekNumberWidth,
                      calendarViewType: CalendarViewType.month,
                      fixedEventSize: 40,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    //return Column(children: [buildMonthHeader(context), buildWeeks()]);
  }

  Widget buildMonthHeader(BuildContext context) {
    List<Widget> headers = [];
    for (int i = 0; i < DateTime.daysPerWeek; i++) {
      DateTime date = startDate.incDays(i);
      if (i == 0) {
        headers.add(SizedBox(width: weekNumberWidth));
      }
      headers.add(
        Expanded(
          child: DateHeader(
            headerType: DateHeaderType.day,
            date: date,
            fontSize: 14,
            textAlign: TextAlign.center,
            padding: const EdgeInsets.all(10.0),
            dateFormat:
                settings.calcHeaderFormat(MediaQuery.of(context).size.width),
          ),
        ),
      );
    }

    return Container(
      width: daysWidth + weekNumberWidth,
      color: schedulerSettings.headerBackgroundColor,
      child: Row(children: headers),
    );
  }

  CellPainter? buildCellDateHeader(BuildContext context) {
    GridCell? cell = UIService.findWidgetByContext<GridCell>(context);
    if (cell == null || cell.date == null) {
      return null;
    }

    return MonthCellHeader(
      cell: cell,
      context: context,
      startDate: pageDate,
      currentMonth: currentMonth,
    );
  }

  Widget buildWeekNumber(BuildContext context, DateTime date, double height) {
    String weekNumber = date.addDays(1, true).getISOWeek.toString();
    String caption = settings.rotateWeekNumber
        ? '${settings.weekNumberCaption} $weekNumber'
        : weekNumber;

    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      width: weekNumberWidth,
      height: height > 0 ? height : null,
      decoration: BoxDecoration(
        color: backgroundColor?.lighten(0.02),
        border: Border(
          bottom: BorderSide(
            color: schedulerSettings.getIntervalLineColor(context),
            width: schedulerSettings.dividerLineWidth,
          ),
        ),
      ),
      child: RotatedBox(
        quarterTurns: settings.rotateWeekNumber ? 3 : 0,
        child: Center(
          child: FittedBox(child: Text(caption)),
        ),
      ),
    );
  }
}
