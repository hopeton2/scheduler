import 'scheduler.dart';

const kSmallDevice = 450;
const kMediumDevice = 700;
const kLargeDevice = 1400;
const double kMobileViewWidth = 767;


const kViewDayCaption  = 'DAY';
const kViewWeekCaption  = 'WEEK';
const kViewWorkWeekCaption  = 'WORK WEEK';
const kViewMonthCaption = 'MONTH';
const kViewTimelineDayCaption = 'TIMELINE';
const kViewTimelineWeekCaption = 'TIMELINE WEEK';
const kViewTimelineWorkWeekCaption = 'TIMELINE WORK WEEK';
const kViewTimelineMonthCaption = 'TIMELINE MONTH';
const kViewTimelineQuarterCaption = 'TIMELINE QUARTER';
const kViewYearCaption = 'YEAR';
const kViewAgendaCaption = 'AGENDA';
const kViewSelectionCaption =  'Select a view...';
const kTodayCaption = 'Today';

const kViewTypes = <CalendarViewType>[
  CalendarViewType.day,
  CalendarViewType.week,
  CalendarViewType.workWeek,
  CalendarViewType.month,
  CalendarViewType.timelineDay,
 /*  CalendarViewType.timelineWeek, */
 /*  CalendarViewType.timelineWorkWeek, */
 /*  CalendarViewType.timelineMonth, */
 /*  CalendarViewType.quarter, */
  CalendarViewType.year,
  CalendarViewType.agenda,
];

const kViewCaptions = <String>[
  kViewDayCaption,
  kViewWeekCaption,
  kViewWorkWeekCaption,
  kViewMonthCaption,
  kViewTimelineDayCaption,
 /*  kViewTimelineWeekCaption, */
 /*  kViewTimelineWorkWeekCaption, */
 /*  kViewTimelineMonthCaption, */
 /*  kViewTimelineQuarterCaption, */
  kViewYearCaption,
  kViewAgendaCaption,
];