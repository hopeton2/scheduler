part of scheduler;

class TimelineView extends StatefulWidget {
  final int pages;
  final double minIntervalWidth;
  const TimelineView({
    Key? key,
    this.pages = 3,
    this.minIntervalWidth = 25,
  }) : super(key: key);

  // IntervalConfig get intervalConfig => IntervalConfig(
  //     intervalMinute: intervalMinute, proposedDate: date);

  @override
  _TimelineViewState createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> with IntervalConfig {
  final _scrollController = ScrollController();
  TimelineViewSettings timelineViewSettings =
      SchedulerService().timelineViewSettings;
  SchedulerSettings schedulerSettings = SchedulerService().schedulerSettings;
  Scheduler scheduler = SchedulerService().scheduler;
  DateRange dateRange = DateRange();
  List<TimeSlot> timeSlots = [];
  AppointmentRenderService? appointmentRenderService;

  late double intervalWidth;
  late int intervalsPerPage;
  late double width;
  late int intervalGroupsPerPage;

  @override
  void initState() {
    intervalMinute = timelineViewSettings.intervalMinute;
    super.initState();
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SchedulerView(viewBuilder: buildTimelineView);
  }

  Widget buildTimelineView(BuildContext context, BoxConstraints constraints) {
    // intervalWidth = max(25, constraints.maxWidth / widget.intervalsPerPage).ceilToDouble();
    Scheduler scheduler = Scheduler.of(context);
    SchedulerDataSource dataSource = scheduler.dataSource!;
    double maxWidth = constraints.maxWidth;
    double height = constraints.maxHeight;

    DateTime endDate = startDate.incDays(widget.pages, true);

    intervalsPerPage = getIntervalsPerPage(startDate);
    intervalWidth = max(widget.minIntervalWidth, maxWidth / intervalsPerPage)
        .ceilToDouble();
    width = ((intervalsPerPage * intervalWidth).ceilToDouble() +
            schedulerSettings.dividerLineWidth) *
        widget.pages;

    Rect calendarRect = Rect.fromLTWH(0, 0, width, height);
    double dayWidth = width / widget.pages;
    double pixelsPerMinute = dayWidth / scheduler.schedulerSettings.dayDuration.inMinutes;
    var timeSlotSample = TimeSlot(
        startDate,
        startDate.incMinutes(intervalMinute!.value),
        CalendarViewType.day,
        IntervalType.minute,
        intervalWidth,);

    appointmentRenderService = AppointmentRenderService(pixelsPerMinute,
        AnchorPosition.left, timeSlotSample, calendarRect, dayWidth, startDate, null,
        fixedSize: true,);

    List<Widget>? renderAppointments() {
      dataSource.visibleDateRange.setRange(startDate, endDate);
      var visibleItems = dataSource.visibleAppointmentItems;
      for (int i = 0; i < widget.pages; i++) {
        DateTime date = startDate.incDays(i);
        Rect dayRect = Rect.fromLTWH(dayWidth * i, 118, width, height);
        appointmentRenderService?.measureAppointments(
            DateRange(date, date), dayRect, visibleItems,);
      }

      return appointmentRenderService?.renderAppointments(visibleItems);
    }

    return Stack(
      //scrollController: _scrollController,
      children: [
        NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            var position = notification.metrics.pixels;
            var positionOffset = notification.metrics.axis == Axis.vertical ? Offset(0, position) : Offset(position, 0);
            scheduler.setSchedulerScrollPos(positionOffset);
       
            return false;
          },
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.pages,
              itemBuilder: (context, index) {
                DateTime date = incrementPageDate(startDate, multiplier: index);

                return buildViewBody(date, constraints.maxWidth, index > 0);
              },
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: dataSource,
          builder: (BuildContext context, value, Widget? child) =>
              ScrollableStack(
            scrollController: _scrollController,
            children: [...?renderAppointments()],
          ),
        ),
      ],
    );
  }

  Widget buildViewBody(DateTime date, double maxWidth, bool showDivider) {
    final headerKey = GlobalKey();
    DateTime groupDate = date.startOfDay;

    intervalsPerPage = getIntervalsPerPage(date);
    intervalWidth = max(widget.minIntervalWidth, maxWidth / intervalsPerPage).ceilToDouble();
    width = (intervalsPerPage * intervalWidth).ceilToDouble() + schedulerSettings.dividerLineWidth;
    intervalGroupsPerPage = getGroupsPerPage(date);

    List<Widget> groupCells = [];
    for (int i = 0; i < intervalGroupsPerPage; i++) {
      groupCells.add(buildIntervalGroupCells(
        i,
        intervalWidth,
        groupDate,
        showDivider && groupDate == groupDate.startOfDay,
      ));
      groupDate = incrementIntervalGroupDate(groupDate);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: headerKey,
          color: schedulerSettings.headerBackgroundColor,
          child: Column(children: [
            DateHeader(
              headerType: DateHeaderType.day,
              width: width,
              date: date,
              fontSize: 23,
              textAlign: TextAlign.left,
              showDivider: showDivider,
              padding: const EdgeInsets.all(10.0),
              dateFormat: periodHeaderFormat,
            ),
            buildGroupHeadings(
                width / getGroupsPerPage(date), date, showDivider,),
          ]),
        ),
        Expanded(child: Row(children: groupCells)),
      ],
    );
  }

  Widget buildGroupHeadings(double width, DateTime date, bool showDivider) {
    List<Widget> groupHeadings = [];

    for (int i = 0; i < getGroupsPerPage(date); i++) {
      DateTime groupDate = incrementIntervalGroupDate(date,
          multiplier: i,); // date.startOfDay.addHours(i, true);
      groupHeadings.add(
        Column(children: [
          DateHeader(
            headerType: groupHeaderType,
            width: width,
            date: groupDate,
            fontSize: timelineViewSettings.timebarFontSize,
            fontColor: schedulerSettings.timebarFontColor,
            showDivider: showDivider && i == 0,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            dateFormat: timeBlockHeaderFormat,
          ),
          if (showIntervalHeadings)
            buildIntervalHeadings(groupDate, showDivider && i == 0),
        ]),
      );
    }

    return Row(children: groupHeadings);
  }

  Widget buildIntervalHeadings(DateTime date, bool showDivider) {
    List<Widget> intervalHeadings = [];
    for (int i = 0; i < getTimeBlockSize(); i++) {
      DateTime intervalDate = incrementIntervalGroupDate(date,
          multiplier: i,
          isInterval:
              true,); //  date.addMinutes(widget.interval.value * i, true);
      intervalHeadings.add(
        DateHeader(
            headerType: DateHeaderType.minute,
            minuteInterval: intervalMinute!.value,
            width: intervalWidth,
            date: intervalDate,
            fontSize: timelineViewSettings.timebarFontSize * .66,
            fontColor: schedulerSettings.timebarMinuteFontColor,
            showDivider: showDivider && i == 0,
            padding: const EdgeInsets.all(2),
            dateFormat: intervalHeaderFormat,),
      );
    }

    return Row(children: intervalHeadings);
  }

  Widget buildIntervalGroupCells(int intervalIndex, double intervalWidth,
      DateTime groupDate, bool showDivider,) {
    showDivider = showTimeBlockDivider(showDivider, groupDate);
    List<Widget> intervalCells = [];
    for (int i = 0; i < getTimeBlockSize(); i++) {
      GlobalKey globalKey = GlobalKey();
      DateTime date = incrementIntervalGroupDate(groupDate,
          multiplier: i,
          isInterval:
              true,); //  groupDate.addMinutes(widget.interval.value * i, true);
      DateTime endDate = date.incMinutes(intervalMinute!.value);
      TimeSlot timeSlot = TimeSlot(date, endDate, CalendarViewType.timelineDay,
          IntervalType.minute, intervalWidth,);
      timeSlots.add(timeSlot);
      intervalCells.add(TimeslotCell(
        timeSlot: timeSlot,
        showDivider: false,
        showBorders:
            date != date.startOfDay || !showTimeBlockDivider(true, date),
        isGroupEnd: i == 0,
        flowOrientation: FlowOrientation.horizontal,
        width: intervalWidth,
        key: globalKey,
      ));
    }

    return Container(
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: schedulerSettings.getDividerLineColor(context),
                  width: schedulerSettings.dividerLineWidth,
                ),
              ),
            )
          : null,
      child: Row(children: intervalCells),
    );
  }
}
