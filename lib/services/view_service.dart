import 'package:flutter/widgets.dart';

import 'appointment_render_service.dart';

class ViewService {
  static final instance = ViewService._internal();
  ViewService._internal();
  
  ValueNotifier<DateTime?> scrollSnapback = ValueNotifier(null);

  Rect? allDayRect;
  AppointmentRenderService? allDayRenderService;
  AppointmentRenderService? allDayHostRenderService;

  clearAllDayHostTracking () {
    allDayRect = null;
    allDayRenderService = null;
    allDayHostRenderService = null;
  }
}

