import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:flutter/material.dart';

enum AppBarBackType { Back, Close, None }

const double kNavigationBarHeight = 59.0;

class MyAppBar extends AppBar implements PreferredSizeWidget {
  MyAppBar(
      {Key key,
      Widget title,
      AppBarBackType leadingType,
      WillPopCallback onWillPop,
      Widget leading,
      Brightness brightness,
      Color backgroundColor,
      List<Widget> actions,
      bool centerTitle = false,
      double elevation,
      BuildContext context,
      })
      : super(
          key: key,
          title: title ??
              Padding(
                padding: const EdgeInsets.only(right: 38, top: 6),
                child: Row(
                  children: [
                    PngIcons.barLogo,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text:
                              'Türkmenistanyň Maliýe we Ykdysadyýet Ministrligi'
                                  .toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).orientation == Orientation.landscape
                                ? MediaQuery.of(context).size.height * 0.025
                                : MediaQuery.of(context).size.width * 0.033,
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
          backgroundColor: const Color(Constants.appBlue),
          centerTitle: centerTitle,
          brightness: Brightness.dark,
          automaticallyImplyLeading: false,
          actions: actions,
          elevation: elevation ?? 2,
        );
  @override
  get preferredSize => Size.fromHeight(kNavigationBarHeight);
}

class AppBarBack extends StatelessWidget {
  final AppBarBackType _backType;
  final Color color;
  final WillPopCallback onWillPop;

  AppBarBack(this._backType, {this.onWillPop, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final willBack = onWillPop == null ? true : await onWillPop();
        if (!willBack) return;
        Navigator.pop(context);
      },
      child: _backType == AppBarBackType.Close
          ? Container(
              child: Icon(
                Icons.close,
                color: color ?? Color(0xFFFAF9F9),
                size: 24.0,
              ),
            )
          : Container(
              padding: EdgeInsets.only(right: 15),
              child: Image.asset(
                'assets/png/nav/nav_back.png',
                color: color,
              ),
            ),
    );
  }
}
