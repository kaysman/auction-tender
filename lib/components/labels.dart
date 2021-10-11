import 'package:maliye_app/config/constants.dart';
import 'package:flutter/material.dart';

class BlueLabel extends StatelessWidget {
  final String label;

  const BlueLabel({Key key, @required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        color: const Color(Constants.appBlue),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({
    Key key,
    @required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text.rich(
          TextSpan(
            text: label,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
