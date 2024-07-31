import 'package:flutter/material.dart';
mixin OverlayMixin<T extends StatefulWidget> on State<T> {

  OverlayEntry? _overlayEntry;
  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }


  void insertOverlay(Widget child) {
    _overlayEntry = OverlayEntry(
      builder: (_) => child,
    );
    OverlayState? overlayState = Overlay.of(context);
    if (overlayState != null) {
      overlayState.insert(_overlayEntry!);
    }
  }

}