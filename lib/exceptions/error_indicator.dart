import 'dart:io';

import 'package:flutter/material.dart';

import 'generic_error_indicator.dart';
import 'no_connection_error.dart';

/// Based on the received error, displays either a [NoConnectionIndicator] or
/// a [GenericErrorIndicator].
class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    @required this.error,
    this.onTryAgain,
    Key key,
  })  : assert(error != null),
        super(key: key);

  final dynamic error;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) => error is SocketException
      ? NoConnectionIndicator(
          onTryAgain: onTryAgain,
        )
      : GenericErrorIndicator(
          onTryAgain: onTryAgain,
        );
}
