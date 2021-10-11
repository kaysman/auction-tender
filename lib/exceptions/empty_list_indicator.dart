import 'package:flutter/material.dart';

import 'exception_indicator.dart';

/// Indicates that no items were found.
class EmptyListIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const ExceptionIndicator(
        title: '',
        message: 'We couldn\'t find any results matching your applied filters.',
        assetName: 'assets/png/empty-box.png',
      );
}
