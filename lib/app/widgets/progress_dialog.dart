import 'dart:async';

import 'package:flutter/material.dart';

class ProgressDialog {
  Completer<void> _dialogCompleter = Completer();

  final BuildContext _context;

  ProgressDialog({required BuildContext context}) :
    _context = context;

  Future<void> open() async {
    DialogRoute _route = DialogRoute(
      context: _context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false
    );
    Navigator.of(_context).push(_route);
    await _dialogCompleter.future;
    Navigator.of(_context).removeRoute(_route);
  }

  void close() {
    _dialogCompleter.complete();
    _dialogCompleter = Completer();
  }
}
