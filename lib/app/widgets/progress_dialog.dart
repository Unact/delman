import 'dart:async';

import 'package:flutter/material.dart';

class ProgressDialog {
  Completer<void> _dialogCompleter = Completer();

  final BuildContext _context;

  ProgressDialog({required BuildContext context}) :
    _context = context;

  Future<void> open() async {
    showDialog(
      context: _context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false
    );
    await _dialogCompleter.future;
    Navigator.of(_context).pop();
  }

  void close() {
    _dialogCompleter.complete();
    _dialogCompleter = Completer();
  }
}
