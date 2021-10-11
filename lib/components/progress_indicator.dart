import 'package:flutter/material.dart';

class UploadingFilesProgressBar extends StatelessWidget {
  const UploadingFilesProgressBar({
    Key key,
    @required this.progressMessage,
    @required this.percentage,
  }) : super(key: key);

  final String progressMessage;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Center(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(text: "$progressMessage $percentage%"),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              LinearProgressIndicator(value: percentage / 100),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(color: Colors.black.withAlpha(400)),
    );
  }
}
