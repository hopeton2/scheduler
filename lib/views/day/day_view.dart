part of scheduler;

class DayView extends StatefulWidget {
  final int dayCount;
  const DayView({
    Key? key,
    this.dayCount = 1,
  }) : super(key: key);

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> with IntervalConfig {
  double timebarWidth = schedulerService.dayViewSettings.timebarFullWidth;
  late int interval;
  late int slotsPerHour;
  late int intervalCount;

  late SchedulerSettings schedulerSettings;
  late DayViewSettings dayViewSettings;
  late GridHelper gridService;

  @override
  void initState() {
    intervalMinute = SchedulerService.instance.dayViewSettings.intervalMinute;
    schedulerSettings = SchedulerService.instance.schedulerSettings;
    dayViewSettings = SchedulerService.instance.dayViewSettings;
    interval = schedulerService.dayViewSettings.intervalMinute.value;
    slotsPerHour = 60 ~/ interval;
    intervalCount = slotsPerHour * 24;

    gridService = GridHelper(
      incrementRowDate: (int rowIndex) {
        // Use January 1st as base date for timebar to avoid DST issues
        final baseDate = DateTime(DateTime.now().year, 1, 1);
        final minutes = (60 ~/ slotsPerHour) * rowIndex;
        return baseDate.add(Duration(minutes: minutes));
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SchedulerView(
        viewBuilder: (BuildContext context, BoxConstraints constraints) =>
            buildView(constraints),
      ),
    );
  }

  Widget buildView(BoxConstraints constraints) {
    return VirtualPageView(
      initialDate: startDate,
      itemBuilder: (BuildContext context, pageDate, index) => Column(
        children: [
          Container(
            color: schedulerSettings.headerBackgroundColor,
            child: IntrinsicHeight(
              child: Row(
                children: buildDayHeaders(
                  pageDate,
                  constraints.maxWidth,
                ),
              ),
            ),
          ),
          AlldayEventGrid(
            backgroundColor: Colors.black45,
            colCount: widget.dayCount,
            startDate: pageDate,
            constraints: constraints,
            timebarWidth: dayViewSettings.timebarFullWidth,
            intervalType: IntervalType.day,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double height = constraints.maxHeight;
                double intervalHeight = max(
                  schedulerService.dayViewSettings.intervalMinHeight,
                  height / intervalCount,
                ).ceilToDouble();

                return Container(
                  color: schedulerSettings.backgroundColor,
                  child: EventGrid(
                    key: UniqueKey(),
                    isAllDayHost: true,
                    gridHelper: gridService,
                    cellHeaderBuilder:
                        (BuildContext context, DateTime date, int index) {
                      return TimebarCell(
                        rowIndex: index,
                        colIndex: 0,
                        direction: Axis.vertical,
                        size: Size(timebarWidth, intervalHeight),
                        date: date,
                        intervalBlockSize: slotsPerHour,
                      );
                    },
                    getVisibleAppointments: () => schedulerService
                        .scheduler.dataSource!.visibleAppointmentItemsByDay
                        .where((element) => !element.appointment.isAllDay)
                        .toList(),
                    date: pageDate,
                    dayCount: widget.dayCount,
                    constraints: constraints,
                    intervalHeight: intervalHeight,
                    intervalWidth: 0,
                    showCurrentTimeIndicator: true,
                    orientation: Axis.vertical,
                    intervalType: IntervalType.minute,
                    rowHeaderWidth: dayViewSettings.timebarFullWidth,
                    calendarViewType: CalendarViewType.day,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildDayHeaders(DateTime initialDate, double maxWidth) {
    List<Widget> result = [];
    var dayWidth =
        (maxWidth - dayViewSettings.timebarFullWidth) / widget.dayCount;
    //DateTime initialDate = startDate;
    for (int i = 0; i < widget.dayCount; i++) {
      DateTime date = initialDate.incDays(i);

      //-- all day
      if (i == 0) {
        result.add(Column(
          children: [
            Expanded(
              child: SizedBox(
                height: dayViewSettings.headerHeight,
                width: dayViewSettings.timebarFullWidth,
              ),
            ),
            /*      SizedBox(
              height: 20,
              width: dayViewSettings.timebarFullWidth,
              child: Visibility(
                visible: !SchedulerViewHelper.isMobileLayout(context),
                child: Text(
                  dayViewSettings.allDayCaption,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: schedulerSettings.timebarFontColor,
                  ),
                ),
              ),
            ), */
/*            Container(
              color: schedulerSettings.timebarBackgroundColor,
              height: 5,
              width: dayViewSettings.timebarWidth,
            ), */ // extra margin
          ],
        ));
      }
      result.add(
        Column(
          children: [
            Expanded(
              child: DateHeader(
                isFirstInSeries: i == 0,
                headerType: DateHeaderType.day,
                style: dayViewSettings.headerStyleName,
                width: dayWidth,
                height: dayViewSettings.headerHeight,
                dateVisible: true,
                date: date,
                showDivider: true,
                padding: const EdgeInsets.all(8),
              ),
            ),
            DateHeader(
              headerType: DateHeaderType.allDay,
              date: date,
              width: dayWidth,
              height: 20,
              showDivider: true,
            ),
            /*    DateHeader(
                //not really an allday header; spacer to give the first time (12 AM) in the ruler a margin at the top
                headerType: DateHeaderType.allDay,
                date: date,
                width: dayWidth,
                height: 5,
                backgroundColor: schedulerSettings.backgroundColor,
                showDivider: true)
*/
          ],
        ),
      );
    }

    return result;
  }
}
