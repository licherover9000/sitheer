import 'package:flutter/material.dart';

class MainNavProvider extends ChangeNotifier {
  int _index = 0;

  int get currentIndex => _index;

  void setIndex(int i) {
    if (_index == i) return;
    _index = i;
    notifyListeners();
  }
}
