import 'package:flutter/material.dart';

class MyTimer {
  bool isRunning = false;
  setRunning(bool value) {
    isRunning = value;
  }

  int current = 0;
  setCurrent(int value) {
    current = value;
  }

  int started = 0;
  setStarted(int value) {
    started = value;
  }

  int paused = 0;
  setPaused(int value) {
    paused = value;
  }

  int resumed = 0;
  setResumed(int value) {}

  int restarted = 0;
  setRestarted(int value) {
    restarted = value;
  }
}
