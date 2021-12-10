import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/pages/app/app_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

part 'person_state.dart';
part 'person_view_model.dart';

class PersonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonViewModel>(
      create: (context) => PersonViewModel(context),
      child: PersonView(),
    );
  }
}

class PersonView extends StatefulWidget {
  _PersonViewState createState() => _PersonViewState();
}

class _PersonViewState extends State<PersonView> {
  Completer<void> _dialogCompleter = Completer();

  Future<void> openDialog() async {
    showDialog(
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator()),
      barrierDismissible: false
    );
    await _dialogCompleter.future;
    Navigator.of(context).pop();
  }

  void closeDialog() {
    _dialogCompleter.complete();
    _dialogCompleter = Completer();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonViewModel, PersonState>(
      builder: (context, vm) {
        PersonViewModel vm = context.read<PersonViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: Text('Пользователь'),
            actions: [
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.send),
                onPressed: vm.sendLogs
              )
            ],
          ),
          body: _buildBody(context)
        );
      },
      listener: (context, state) {
        if (state is PersonInProgress) {
          openDialog();
        } else if (state is PersonLogsSent) {
          showMessage(state.message);
        } else if (state is PersonFailure) {
          showMessage(state.message);
        } else if (state is PersonLoggedOut) {
          closeDialog();
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
        }
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    PersonViewModel vm = context.read<PersonViewModel>();

    return ListView(
      padding: EdgeInsets.only(top: 24, bottom: 24),
      children: [
        InfoRow(title: Text('Логин'), trailing: Text(vm.username)),
        InfoRow(title: Text('Курьер'), trailing: Text(vm.name)),
        InfoRow(title: Text('Обновление БД'), trailing: Text(vm.lastSyncTime)),
        InfoRow(title: Text('Версия'), trailing: Text(vm.fullVersion)),
        !vm.newVersionAvailable ? Container() : Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  primary: Colors.blue,
                ),
                child: Text('Обновить приложение'),
                onPressed: vm.launchAppUpdate
              )
            ],
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  primary: Colors.blue,
                ),
                onPressed: vm.apiLogout,
                child: Text('Выйти'),
              ),
            ]
          )
        )
      ]
    );
  }
}
