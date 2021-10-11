import 'package:flutter/material.dart';

import 'indicators.dart';

class SendFileButton extends StatelessWidget {
  const SendFileButton({
    Key key,
    @required this.isUploading,
    @required this.function,
    this.inAppBar = false,
  }) : super(key: key);

  final bool isUploading;
  final Function() function;
  final bool inAppBar;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var whiteColor = const Color(0xffffffff);
    return Container(
      width: size.width,
      height: size.height * 0.05,
      margin: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8.0),
      child: AbsorbPointer(
        absorbing: isUploading,
        child: inAppBar
            ? OutlinedButton(
                onPressed: function,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Ugratmak".toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    isUploading
                        ? const ProgressIndicatorSmall(
                      color: const Color(0xffffffff),
                    )
                        : Icon(Icons.send, color: Color(0xffffffff).withOpacity(0.75))
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: function,
                child: isUploading
                    ? const ProgressIndicatorSmall(
                        color: const Color(0xffffffff)
                      )
                    : Text(
                        "Ugratmak".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
      ),
    );
  }
}
