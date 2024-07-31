import 'package:flutter/material.dart';

import '../services/services.dart';

class JzStatefulWidget extends StatefulWidget {
  const JzStatefulWidget({Key? key}) : super(key: key);

  @override
  _JzStatefulWidgetState createState() => _JzStatefulWidgetState();
}

class _JzStatefulWidgetState extends State<JzStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    schedulerService.currentContext = context;

    return Container();
  }
}
