import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/app.dart';
import '/app/utils/misc.dart';

abstract class PageViewModel<T, P> extends Cubit<T> {
  late final StreamSubscription _subscription;
  late final App app;
  final BuildContext context;

  bool closed = false;

  PageViewModel(this.context, T state) : super(state) {
    initViewModel();
  }

  P get status;

  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([]);

  @mustCallSuper
  Future<void> initViewModel() async {
    app = await App.init();
    _subscription = app.storage.tableUpdates(listenForTables).listen((event) => loadData());
    await loadData();
  }

  @protected
  Future<void> loadData();

  @override
  void emit(T state) {
    Map<String, String> stackFrame = Misc.stackFrame(1);
    FLog.info(
      className: stackFrame['className'],
      methodName: stackFrame['methodName'],
      text: status.runtimeType.toString()
    );

    if (!closed) super.emit(state);
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    closed = true;

    super.close();
  }
}
