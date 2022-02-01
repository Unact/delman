import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/entities/entities.dart';
import '/app/constants/strings.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/services/api.dart';

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
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

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
          if (state.status.isInitial || state.status.isUrlFieldActivated) {
            _loginController.text = state.login;
            _passwordController.text = state.password;
            _urlController.text = state.url;
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _buildLoginForm(context),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text('Версия ${state.fullVersion}')
              )
            ]
          );
        },
        listener: (context, state) {
          switch (state.status) {
            case LoginStateStatus.passwordSent:
            case LoginStateStatus.failure:
              showMessage(state.message);
              closeDialog();
              break;
            case LoginStateStatus.loggedIn:
              closeDialog();
              break;
            case LoginStateStatus.inProgress:
              openDialog();
              break;
            default:
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
            controller: _loginController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Телефон или e-mail или login',
            ),
          ),
          TextField(
            controller: _passwordController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Пароль'
            ),
          ),
          vm.state.showUrl ? TextField(
            controller: _urlController,
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
                      vm.apiLogin(_urlController.text, _loginController.text, _passwordController.text);
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
                      vm.getNewPassword(_urlController.text, _loginController.text);
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
