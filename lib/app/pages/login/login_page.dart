import 'dart:async';
import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/pages/app/app_page.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'login_state.dart';
part 'login_view_model.dart';

class LoginPage extends StatelessWidget {
  LoginPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginViewModel>(
      create: (context) => LoginViewModel(context),
      child: _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  Completer<void> _dialogCompleter = Completer();

  Future<void> openDialog() async {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false
    );
    await _dialogCompleter.future;
    Navigator.of(context).pop();
  }

  void closeDialog() {
    _dialogCompleter.complete();
    _dialogCompleter = Completer();
  }

  void unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Войти в приложение'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: BlocConsumer<LoginViewModel, LoginState>(
        builder: (context, state) {
          LoginViewModel vm = context.read<LoginViewModel>();

          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _buildLoginForm(context),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text('Версия ${vm.fullVersion}')
              )
            ]
          );
        },
        listener: (context, state) {
          if (state is LoginInProgress) {
            openDialog();
          } else if (state is LoginFailure) {
            showMessage(state.message);
            closeDialog();
          } else if (state is LoginPasswordSent) {
            showMessage(state.message);
            closeDialog();
          } else if (state is LoginLoggedIn) {
            closeDialog();
          }
        },
      )
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    LoginViewModel vm = context.read<LoginViewModel>();

    return SizedBox(
      height: 320,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        children: <Widget>[
          TextField(
            controller: TextEditingController(text: vm.login),
            onChanged: vm.setLogin,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Телефон или e-mail или login',
            ),
          ),
          TextField(
            controller: TextEditingController(text: vm.password),
            onChanged: vm.setPassword,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Пароль'
            ),
          ),
          vm.showUrl ? TextField(
            controller: TextEditingController(text: vm.url),
            onChanged: vm.setUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Url'
            ),
          ) : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: SizedBox(
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
                    child: const Text('Войти'),
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: SizedBox(
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
                    child: const Text('Получить пароль', textAlign: TextAlign.center,),
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
