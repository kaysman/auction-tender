import 'package:maliye_app/config/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({Key key, @required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        color: Colors.white,
        padding: Constants.innerPadding,
        child: child,
      ),
    );
  }
}
