import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/repositories/app_repository.dart';
import '/app/repositories/users_repository.dart';

part 'person_state.dart';
part 'person_view_model.dart';

class PersonPage extends StatelessWidget {
  PersonPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonViewModel>(
      create: (context) => PersonViewModel(
        RepositoryProvider.of<AppRepository>(context),
        RepositoryProvider.of<UsersRepository>(context)
      ),
      child: _PersonView(),
    );
  }
}

class _PersonView extends StatefulWidget {
  @override
  _PersonViewState createState() => _PersonViewState();
}

class _PersonViewState extends State<_PersonView> {
  late final ProgressDialog _progressDialog = ProgressDialog(context: context);

  @override
  void dispose() {
    _progressDialog.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonViewModel, PersonState>(
      builder: (context, vm) {
        PersonViewModel vm = context.read<PersonViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Пользователь'),
            actions: [
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.send),
                onPressed: vm.sendLogs
              )
            ],
          ),
          body: _buildBody(context)
        );
      },
      listener: (context, state) async {
        switch (state.status) {
          case PersonStateStatus.inProgress:
            await _progressDialog.open();
            break;
          case PersonStateStatus.failure:
          case PersonStateStatus.logsSend:
            Misc.showMessage(context, state.message);
            _progressDialog.close();
            break;
          case PersonStateStatus.loggedOut:
            _progressDialog.close();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
            break;
          default:
        }
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    PersonViewModel vm = context.read<PersonViewModel>();
    PersonState state = vm.state;

    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      children: [
        InfoRow(title: const Text('Логин'), trailing: Text(state.user?.username ?? '')),
        InfoRow(
          title: const Text('Курьер'),
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.qr_code_2),
                onPressed: () => QRDialog(context: context, qr: vm.state.user?.storageQR ?? '').open()
              ),
              Expanded(child: Text(state.user?.name ?? ''))
            ]
          )
        ),
        InfoRow(
          title: const Text('Данные загружены'),
          trailing: Text(
            state.appInfo?.lastLoadTime != null ?
              Format.dateTimeStr(state.appInfo?.lastLoadTime!) :
              'Загрузка не проводилась',
          )
        ),
        InfoRow(
          title: const Text('Версия'),
          trailing: FutureBuilder(
            future: Misc.fullVersion,
            builder: (context, snapshot) => Text(snapshot.data ?? ''),
          )
        ),
        FutureBuilder(
          future: vm.state.user?.newVersionAvailable,
          builder: (context, snapshot) {
            if (!(snapshot.data ?? false)) return Container();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      backgroundColor: Theme.of(context).colorScheme.primary
                    ),
                    onPressed: vm.launchAppUpdate,
                    child: const Text('Обновить приложение'),
                  )
                ],
              )
            );
          }
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: vm.apiLogout,
                child: const Text('Выйти'),
              ),
            ]
          )
        )
      ]
    );
  }
}
