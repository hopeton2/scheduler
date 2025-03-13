part of scheduler;

enum SizingDirection { none, left, right, up, down }

enum ViewPart { header, body }

enum HeaderPosition { columnStart, rowStart }

enum AnchorPosition { left, top }

enum FlowOrientation { horizontal, vertical }

enum CalendarViewType {
  day,
  week,
  workWeek,
  month,
  quarter,
  year,
  agenda,
  timelineDay,
  timelineWeek,
  timelineWorkWeek,
  timelineMonth
}

enum DateHeaderType {
  day,
  hour,
  minute,
  month,
  allDay,
}

enum IntervalType {
  minute,
  hour,
  day,
  week,
  month,
  quarter,
  year,
}

enum IntervalMinute {
  min5,
  min10,
  min15,
  min20,
  min30,
  min60,
}

extension IntervalExtension on IntervalMinute {
  int get value {
    switch (this) {
      case IntervalMinute.min5:
        return 5;
      case IntervalMinute.min10:
        return 10;
      case IntervalMinute.min15:
        return 15;
      case IntervalMinute.min20:
        return 20;
      case IntervalMinute.min30:
        return 30;
      case IntervalMinute.min60:
        return 60;
    }
  }
}

/// Types of recurrence patterns for recurring appointments
enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

enum NavigationState {
  idle,
  forward,
  backward,
  dragging,
  jump,
}
