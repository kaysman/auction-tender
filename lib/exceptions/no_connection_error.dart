import 'package:flutter/material.dart';

import 'exception_indicator.dart';

/// Indicates that a connection error occurred.
class NoConnectionIndicator extends StatelessWidget {
  const NoConnectionIndicator({
    Key key,
    this.onTryAgain,
  }) : super(key: key);

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) => ExceptionIndicator(
        title: 'No connection',
        message: 'Please check internet connection and try again.',
        assetName: 'assets/png/frustrated-face.png',
        onTryAgain: onTryAgain,
      );
}
