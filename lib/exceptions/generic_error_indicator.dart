import 'package:flutter/material.dart';

import 'exception_indicator.dart';

/// Indicates that an unknown error occurred.
class GenericErrorIndicator extends StatelessWidget {
  const GenericErrorIndicator({
    Key key,
    this.onTryAgain,
  }) : super(key: key);

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) => ExceptionIndicator(
        title: 'Bir zat nädogry boldy',
        message: 'Näbelli ýalňyşlyk ýüze çykdy.\n'
            'Biraz wagtdan gaýtadan synanyşyň.',
        assetName: 'assets/svg/exception.svg',
        onTryAgain: onTryAgain,
      );
}
