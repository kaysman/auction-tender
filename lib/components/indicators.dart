import 'package:flutter/material.dart';
import 'package:maliye_app/config/constants.dart';

class ProgressIndicatorSmall extends StatelessWidget {
  const ProgressIndicatorSmall({
    Key key,
    this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22.0,
      height: 22.0,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: color ?? const Color(Constants.appBlue),
      ),
    );
  }
}
