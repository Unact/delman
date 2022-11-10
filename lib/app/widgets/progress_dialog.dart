import 'dart:async';

import 'package:flutter/material.dart';

class ProgressDialog {
  Completer<void> _dialogCompleter = Completer();

  final BuildContext _context;
  final DialogRoute _route;

  ProgressDialog({required BuildContext context}) :
    _context = context,
    _route = DialogRoute(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false
    );

  Future<void> open() async {
    Navigator.of(_context).push(_route);
    await _dialogCompleter.future;
    Navigator.of(_context).removeRoute(_route);
  }

  void close() {
    _dialogCompleter.complete();
    _dialogCompleter = Completer();
  }
}
