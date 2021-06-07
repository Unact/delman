import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/view_models/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginViewModel? _loginViewModel;
  Completer<void> _dialogCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _loginViewModel = context.read<LoginViewModel>();
    _loginViewModel!.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _loginViewModel!.removeListener(this.vmListener);
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
    switch (_loginViewModel!.state) {
      case LoginState.InProgress:
        openDialog();
        break;
      case LoginState.Failure:
      case LoginState.PasswordSent:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_loginViewModel!.message!)));
        closeDialog();
        break;
      case LoginState.LoggedIn:
        closeDialog();
        break;
      default:
    }
  }

  void unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Войти в приложение'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _buildLoginForm(context),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text('Версия ${vm.fullVersion}')
              )
            ]
          );
        }
      )
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    LoginViewModel vm = Provider.of<LoginViewModel>(context);

    return Container(
      height: 320,
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        children: <Widget>[
          TextField(
            controller: TextEditingController(text: vm.login),
            onChanged: vm.setLogin,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Телефон или e-mail или login',
            ),
          ),
          TextField(
            controller: TextEditingController(text: vm.password),
            onChanged: vm.setPassword,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Пароль'
            ),
          ),
          vm.showUrl ? TextField(
            controller: TextEditingController(text: vm.url),
            onChanged: vm.setUrl,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Url'
            ),
          ) : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Container(
                  width: 160,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      primary: Colors.blue,
                    ),
                    onPressed: () {
                      unfocus();
                      vm.apiLogin();
                    },
                    child: Text('Войти'),
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Container(
                  width: 160,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      primary: Colors.blue,
                    ),
                    onPressed: () {
                      unfocus();
                      vm.getNewPassword();
                    },
                    child: Text('Получить пароль', textAlign: TextAlign.center,),
                  ),
                )
              ),
            ],
          ),
        ],
      )
    );
  }
}
