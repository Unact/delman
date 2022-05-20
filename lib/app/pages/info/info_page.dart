import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/pages/home/home_page.dart';
import '/app/pages/person/person_page.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/services/api.dart';
import '/app/utils/format.dart';
import '/app/utils/geo_loc.dart';
import '/app/widgets/widgets.dart';

part 'info_state.dart';
part 'info_view_model.dart';

class InfoPage extends StatelessWidget {
  InfoPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoViewModel>(
      create: (context) => InfoViewModel(context),
      child: _InfoView(),
    );
  }
}

class _InfoView extends StatefulWidget {
  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<_InfoView> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Completer<void> _refresherCompleter = Completer();
  late final ProgressDialog _progressDialog = ProgressDialog(context: context);

  Future<void> openRefresher() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState!.show();
    });
  }

  void closeRefresher() {
    _refresherCompleter.complete();
    _refresherCompleter = Completer();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.ruAppName),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.person),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
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
        listener: (context, state) async {
          switch (state.status) {
            case InfoStateStatus.inCloseProgress:
              await _progressDialog.open();
              break;
            case InfoStateStatus.startLoad:
              await openRefresher();
              break;
            case InfoStateStatus.closeFailure:
            case InfoStateStatus.closeSuccess:
              showMessage(state.message);
              _progressDialog.close();
              break;
            case InfoStateStatus.loadFailure:
            case InfoStateStatus.loadSuccess:
              showMessage(state.message);
              closeRefresher();
              break;
            default:
              break;
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
    InfoState state = vm.state;

    return Card(
      child: ListTile(
        onTap: () => vm.changePage(3),
        isThreeLine: true,
        title: const Text(Strings.orderStoragesPageName),
        subtitle: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey),
            children: <TextSpan>[
              TextSpan(
                text: 'Забрать со склада: ${state.ordersNotInOwnStorageCnt}\n',
                style: const TextStyle(fontSize: 12.0)
              ),
              TextSpan(text: 'У меня: ${state.ordersInOwnStorageCnt}\n', style: const TextStyle(fontSize: 12.0))
            ]
          )
        )
      ),
    );
  }

  Widget _buildDeliveriesCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();
    InfoState state = vm.state;

    return Card(
      child: ListTile(
        onTap: () => vm.changePage(1),
        isThreeLine: true,
        title: const Text(Strings.deliveryPageName),
        subtitle: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey),
            children: <TextSpan>[
              TextSpan(
                text: state.deliveries.map((e) => Format.dateStr(e.delivery.deliveryDate)).join('\n') + '\n',
                style: const TextStyle(fontSize: 12.0)
              ),
              TextSpan(text: 'Точек: ${state.deliveryPointsCnt}\n', style: const TextStyle(fontSize: 12.0)),
              TextSpan(text: 'Осталось: ${state.deliveryPointsLeftCnt}\n', style: const TextStyle(fontSize: 12.0))
            ]
          )
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            primary: Colors.blue,
          ),
          child: const Text('Завершить день'),
          onPressed: state.deliveryPointsCnt == 0 ? null : vm.closeDelivery
        ),
      ),
    );
  }

  Widget _buildPaymentsCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();
    InfoState state = vm.state;

    return Card(
      child: ListTile(
        onTap: () => vm.changePage(2),
        isThreeLine: true,
        title: const Text(Strings.paymentsPageName),
        subtitle: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey),
            children: <TextSpan>[
              TextSpan(
                text: 'Всего: ${state.paymentsCnt} на сумму ${Format.numberStr(state.paymentsSum)}\n',
                style: const TextStyle(fontSize: 12.0)
              ),
              TextSpan(
                text: 'Наличными: ${state.cashPaymentsCnt} на сумму ${Format.numberStr(state.cashPaymentsSum)}\n',
                style: const TextStyle(fontSize: 12.0)
              ),
              TextSpan(
                text: 'Картой: ${state.cardPaymentsCnt} на сумму ${Format.numberStr(state.cardPaymentsSum)}\n',
                style: const TextStyle(fontSize: 12.0)
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

    if (state.status == InfoStateStatus.loadFailure) {
      return Card(
        child: ListTile(
          isThreeLine: true,
          title: const Text('Ошибки'),
          subtitle: Text(state.message, style: TextStyle(color: Colors.red[300])),
        )
      );
    } else {
      return Container();
    }
  }

  Widget _buildInfoCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();
    InfoState state = vm.state;

    if (state.newVersionAvailable) {
      return const Card(
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
