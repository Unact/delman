import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/pages/app/app_page.dart';
import 'package:delman/app/utils/misc.dart';

abstract class PageViewModel<T> extends Cubit<T> {
  final BuildContext context;

  bool closed = false;
  AppViewModel appViewModel;

  PageViewModel(this.context, T state) :
    appViewModel = context.read<AppViewModel>(),
    super(state);

  @override
  void emit(T state) {
    Map<String, String> stackFrame = Misc.stackFrame(1);
    FLog.info(
      className: stackFrame['className'],
      methodName: stackFrame['methodName'],
      text: state.runtimeType.toString()
    );

    if (!closed) super.emit(state);
  }

  @override
  Future<void> close() async {
    closed = true;
    super.close();
  }
}
