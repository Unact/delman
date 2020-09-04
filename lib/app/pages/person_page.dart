import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/pages/login_page.dart';
import 'package:delman/app/view_models/login_view_model.dart';
import 'package:delman/app/view_models/person_view_model.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({Key key}) : super(key: key);

  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PersonViewModel _personViewModel;
  Completer<void> _dialogCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _personViewModel = context.read<PersonViewModel>();
    _personViewModel.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _personViewModel.removeListener(this.vmListener);
    super.dispose();
  }

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

  Future<void> vmListener() async {
    switch (_personViewModel.state) {
      case PersonState.InProgress:
        openDialog();
        break;
      case PersonState.Failure:
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(_personViewModel.message)));
        closeDialog();
        break;
      case PersonState.LoggedOut:
        closeDialog();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Пользователь')
      ),
      body: Consumer<PersonViewModel>(
        builder: (context, vm, _) {
          return _buildBody(context);
        }
      )
    );
  }

  Widget _buildBody(BuildContext context) {
    PersonViewModel vm = Provider.of<PersonViewModel>(context);

    return ListView(
      padding: EdgeInsets.only(top: 24, bottom: 24),
      children: [
        ListTile(
          leading: Text('Логин'),
          trailing: Text(vm.username),
          dense: true
        ),
        ListTile(
          leading: Text('Курьер'),
          trailing: Text(vm.courierName),
          dense: true
        ),
        ListTile(
          leading: Text('Обновление БД'),
          trailing: Text(vm.lastSyncTime),
          dense: true
        ),
        ListTile(
          leading: Text('Версия'),
          trailing: Text(vm.version),
          dense: true
        ),
        !vm.newVersionAvailable ? Container() : Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                child: Text('Обновить приложение'),
                onPressed: vm.launchAppUpdate,
                color: Colors.blueAccent,
                textColor: Colors.white,
              )
            ],
          )
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                onPressed: vm.apiLogout,
                child: Text('Выйти', style: TextStyle(color: Colors.white)),
              ),
            ]
          )
        )

      ]
    );
  }
}
