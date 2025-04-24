import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  final Duration delay;
  VoidCallback? _action;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback action) {
    _action = action;
    _timer?.cancel(); // Сбрасываем предыдущий таймер

    _timer = Timer(delay, () {
      _action?.call();
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}