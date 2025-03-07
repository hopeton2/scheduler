import 'package:dart_date/dart_date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/date_range.dart';
import 'package:scheduler/services/fab_service.dart';
import 'package:scheduler/time_slot.dart';

class SlotSelector extends ChangeNotifier {
  DateRange selectedSlotDates = DateRange();
  TimeSlot? _selectionStartSlot;
  TimeSlot? _selectionEndSlot;
  bool isSelecting = false;
  bool isSelectable = true;

  get durationOfSlots => Duration(
      minutes: _selectionEndSlot!.endDate
          .differenceInMinutes(_selectionStartSlot!.startDate));

  startSelection(TimeSlot slot) {
    if (isSelecting || isSelectable) {
      return;
    }
    _selectionStartSlot = slot;
    isSelecting = true;
    selectRange(slot, slot);
  }

  endSelection() {
    isSelecting = false;
    if (_selectionStartSlot != null && _selectionEndSlot != null) {
      // Notify that selection has ended
      notifyListeners();
    }
  }

  selectRange(TimeSlot startSlot, TimeSlot endSlot) {
    _selectionStartSlot = startSlot;
    _selectionEndSlot = endSlot;
    selectedSlotDates.setRange(startSlot.startDate, endSlot.startDate);
    notifyListeners();
  }

  select(TimeSlot slot) {
    selectRange(_selectionStartSlot!, slot);
  }

  clearSelection() {
    selectedSlotDates.clearRange();
    notifyListeners();
  }

  void showAppointmentEditorFromSelection(BuildContext context) {
    if (_selectionStartSlot != null && _selectionEndSlot != null) {
      // Get the start and end dates from selection
      final startDate = _selectionStartSlot!.startDate;
      final endDate = _selectionEndSlot!.endDate;

      // Show the appointment editor
      FabService.instance.showAppointmentEditor(
        context,
        initialStartDate: startDate,
        initialEndDate: endDate,
      );

      // Clear the selection
      clearSelection();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    listener();
  }
}
