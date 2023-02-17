import 'dart:async';
import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:drift/drift.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/services/api.dart';
import '/app/utils/format.dart';
import '/app/widgets/widgets.dart';

part 'person_state.dart';
part 'person_view_model.dart';

class PersonPage extends StatelessWidget {
  PersonPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonViewModel>(
      create: (context) => PersonViewModel(context),
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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
              Text(state.user?.name ?? '')
            ]
          )
        ),
        InfoRow(
          title: const Text('Обновление БД'),
          trailing: Text(state.lastSyncTime != null ? Format.dateTimeStr(state.lastSyncTime) : 'Не проводилось')
        ),
        InfoRow(title: const Text('Версия'), trailing: Text(state.fullVersion)),
        !state.newVersionAvailable ?
          Container() :
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Обновить приложение'),
                  onPressed: vm.launchAppUpdate
                )
              ],
            )
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
                  backgroundColor: Colors.blue,
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
