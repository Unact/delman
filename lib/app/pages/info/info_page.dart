import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/home/home_page.dart';
import 'package:delman/app/pages/person/person_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/pages/app/app_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'info_state.dart';
part 'info_view_model.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoViewModel>(
      create: (context) => InfoViewModel(context),
      child: InfoView(),
    );
  }
}

class InfoView extends StatefulWidget {
  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Completer<void> _refresherCompleter = Completer();
  Completer<void> _dialogCompleter = Completer();

  Future<void> openRefresher() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState!.show();
    });
  }

  void closeRefresher() {
    _refresherCompleter.complete();
    _refresherCompleter = Completer();
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.ruAppName),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.person),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => PersonPage(),
                  fullscreenDialog: true
                )
              );
            }
          )
        ]
      ),
      body: BlocConsumer<InfoViewModel, InfoState>(
        builder: (context, state) {
          InfoViewModel vm = context.read<InfoViewModel>();

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              vm.refresh();
              return _refresherCompleter.future;
            },
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildInfoCards(context)
                )
              ],
            )
          );
        },
        listener: (context, state) {
          if (state is InfoInCloseProgress) {
            openDialog();
          } else if (state is InfoCloseFailure) {
            showMessage(state.message);
            closeDialog();
          } else if (state is InfoCloseSuccess) {
            showMessage(state.message);
            closeDialog();
          } else if (state is InfoLoadFailure) {
            showMessage(state.message);
            closeRefresher();
          } else if (state is InfoLoadSuccess) {
            showMessage(state.message);
            closeRefresher();
          }
        },
      )
    );
  }

  List<Widget> _buildInfoCards(BuildContext context) {
    return <Widget>[
      _buildDeliveriesCard(context),
      _buildPaymentsCard(context),
      _buildOrderStoragesCard(context),
      _buildFailureCard(context),
      _buildInfoCard(context),
    ];
  }

  Widget _buildOrderStoragesCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();

    return Card(
      child: ListTile(
        onTap: () => vm.changePage(3),
        isThreeLine: true,
        title: Text(Strings.orderStoragesPageName),
        subtitle: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey),
            children: <TextSpan>[
              TextSpan(text: 'Забрать со склада: ${vm.ordersNotInOwnStorageCnt}\n', style: TextStyle(fontSize: 12.0)),
              TextSpan(text: 'У меня: ${vm.ordersInOwnStorageCnt}\n', style: TextStyle(fontSize: 12.0))
            ]
          )
        )
      ),
    );
  }

  Widget _buildDeliveriesCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();

    return Card(
      child: ListTile(
        onTap: () => vm.changePage(1),
        isThreeLine: true,
        title: Text(Strings.deliveryPageName),
        subtitle: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey),
            children: <TextSpan>[
              TextSpan(
                text: vm.deliveries.map((e) => Format.dateStr(e.deliveryDate)).join('\n') + '\n',
                style: TextStyle(fontSize: 12.0)
              ),
              TextSpan(text: 'Точек: ${vm.deliveryPointsCnt}\n', style: TextStyle(fontSize: 12.0)),
              TextSpan(text: 'Осталось: ${vm.deliveryPointsLeftCnt}\n', style: TextStyle(fontSize: 12.0))
            ]
          )
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            primary: Colors.blue,
          ),
          child: Text('Завершить день'),
          onPressed: vm.deliveryPointsCnt == 0 ? null : vm.closeDelivery
        ),
      ),
    );
  }

  Widget _buildPaymentsCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();

    return Card(
      child: ListTile(
        onTap: () => vm.changePage(2),
        isThreeLine: true,
        title: Text(Strings.paymentsPageName),
        subtitle: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey),
            children: <TextSpan>[
              TextSpan(
                text: 'Всего: ${vm.paymentsCnt} на сумму ${Format.numberStr(vm.paymentsSum)}\n',
                style: TextStyle(fontSize: 12.0)
              ),
              TextSpan(
                text: 'Наличными: ${vm.cashPaymentsCnt} на сумму ${Format.numberStr(vm.cashPaymentsSum)}\n',
                style: TextStyle(fontSize: 12.0)
              ),
              TextSpan(
                text: 'Картой: ${vm.cardPaymentsCnt} на сумму ${Format.numberStr(vm.cardPaymentsSum)}\n',
                style: TextStyle(fontSize: 12.0)
              )
            ]
          )
        )
      ),
    );
  }

  Widget _buildFailureCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();
    InfoState state = vm.state;

    if (state is InfoTimerLoadFailure) {
      return Card(
        child: ListTile(
          isThreeLine: true,
          title: Text('Ошибки'),
          subtitle: Text(state.message, style: TextStyle(color: Colors.red[300])),
        )
      );
    } else {
      return Container();
    }
  }

  Widget _buildInfoCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();

    if (vm.newVersionAvailable) {
      return Card(
        child: ListTile(
          isThreeLine: true,
          title: Text('Информация'),
          subtitle: Text('Доступна новая версия приложения'),
        )
      );
    } else {
      return Container();
    }
  }
}
