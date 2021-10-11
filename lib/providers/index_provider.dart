import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class IndexProvider with ChangeNotifier {
  PageController tabBarPageController;

  IndexProvider() {
    tabBarPageController = PageController(
      initialPage: getSelectedIndex,
      keepPage: true,
    );
  }

  int selectedIndex = 2;

  int get getSelectedIndex => this.selectedIndex;

  set setIndex(int value) {
    tabBarPageController.animateToPage(
      value,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    selectedIndex = value;
    this.notifyListeners();
  }
}
