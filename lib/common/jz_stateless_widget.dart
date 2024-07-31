import 'package:flutter/material.dart';

import '../services/services.dart';

class JzStatelessWidget extends StatelessWidget {
  const JzStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    schedulerService.currentContext = context;

    return Container();
  }
}
