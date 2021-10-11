import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Basic layout for indicating that an exception occurred.
class ExceptionIndicator extends StatelessWidget {
  const ExceptionIndicator({
    @required this.title,
    @required this.assetName,
    this.message,
    this.onTryAgain,
    Key key,
  })  : assert(title != null),
        assert(assetName != null),
        super(key: key);
  final String title;
  final String message;
  final String assetName;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) => Center(
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          elevation: 0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  assetName,
                  height: MediaQuery.of(context).size.width * 0.3,
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6,
                ),
                if (message != null)
                  const SizedBox(
                    height: 16,
                  ),
                if (message != null)
                  Text(
                    message,
                    textAlign: TextAlign.center,
                  ),
                if (onTryAgain != null)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                if (onTryAgain != null)
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onTryAgain,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Täzeden synanş',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
