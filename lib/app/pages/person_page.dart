import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/view_models/person_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({Key? key}) : super(key: key);

  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  PersonViewModel? _personViewModel;
  Completer<void> _dialogCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _personViewModel = context.read<PersonViewModel>();
    _personViewModel!.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _personViewModel!.removeListener(this.vmListener);
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
    switch (_personViewModel!.state) {
      case PersonState.InProgress:
        openDialog();
        break;
      case PersonState.LogsSent:
      case PersonState.Failure:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_personViewModel!.message!)));
        closeDialog();
        break;
      case PersonState.LoggedOut:
        closeDialog();
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonViewModel>(
      builder: (context, vm, _) {
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
      }
    );
  }

  Widget _buildBody(BuildContext context) {
    PersonViewModel vm = Provider.of<PersonViewModel>(context);

    return ListView(
      padding: EdgeInsets.only(top: 24, bottom: 24),
      children: [
        InfoRow(title: Text('Логин'), trailing: Text(vm.username)),
        InfoRow(title: Text('Курьер'), trailing: Text(vm.courierName)),
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
