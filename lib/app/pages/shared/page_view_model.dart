import 'dart:async';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_app_utils/u_app_utils.dart';

abstract class PageViewModel<T, P> extends Cubit<T> {
  PageViewModel(T state) : super(state) {
    initViewModel();
  }

  P get status;

  @mustCallSuper
  Future<void> initViewModel() async {}

  @override
  void emit(T state) {
    Map<String, String> stackFrame = Misc.stackFrame(1);
    FLog.info(
      className: stackFrame['className'],
      methodName: stackFrame['methodName'],
      text: status.runtimeType.toString()
    );

    if (!isClosed) super.emit(state);
  }
}
