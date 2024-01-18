import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/pages/home/home_page.dart';
import '/app/pages/person/person_page.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/repositories/app_repository.dart';
import '/app/repositories/deliveries_repository.dart';
import '/app/repositories/users_repository.dart';

part 'info_state.dart';
part 'info_view_model.dart';

class InfoPage extends StatelessWidget {
  InfoPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfoViewModel>(
      create: (context) => InfoViewModel(
        RepositoryProvider.of<AppRepository>(context),
        RepositoryProvider.of<DeliveriesRepository>(context),
        RepositoryProvider.of<UsersRepository>(context),
      ),
      child: _InfoView(),
    );
  }
}

class _InfoView extends StatefulWidget {
  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<_InfoView> {
  final ScrollController scrollController = ScrollController();
  final EasyRefreshController refreshController = EasyRefreshController();
  late final ProgressDialog _progressDialog = ProgressDialog(context: context);

  @override
  void dispose() {
    _progressDialog.close();
    super.dispose();
  }

  void changePage(int index) {
    final homeVm = context.read<HomeViewModel>();

    homeVm.setCurrentIndex(index);
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
          final lastLoadTime = state.appInfo?.lastLoadTime != null ?
            Format.dateTimeStr(state.appInfo?.lastLoadTime) :
            'Загрузка не проводилась';

          return Refreshable(
            scrollController: scrollController,
            refreshController: refreshController,
            confirmRefresh: false,
            messageText: 'Последнее обновление: $lastLoadTime',
            onRefresh: vm.getData,
            onError: (error, stackTrace) {
              if (error is! AppError) Misc.reportError(error, stackTrace);
            },
            childBuilder: (context, physics) => ListView(
              physics: physics,
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
            case InfoStateStatus.closeInProgress:
              await _progressDialog.open();
              break;
            case InfoStateStatus.startLoad:
              refreshController.callRefresh(scrollController: scrollController);
              break;
            case InfoStateStatus.closeFailure:
            case InfoStateStatus.closeSuccess:
              Misc.showMessage(context, state.message);
              _progressDialog.close();
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
      _buildInfoCard(context),
    ];
  }

  Widget _buildOrderStoragesCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();
    InfoState state = vm.state;

    return Card(
      child: ListTile(
        onTap: () => changePage(3),
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
        onTap: () => changePage(1),
        isThreeLine: true,
        title: const Text(Strings.deliveryPageName),
        subtitle: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey),
            children: <TextSpan>[
              TextSpan(
                text: '${state.deliveries.map((e) => Format.dateStr(e.delivery.deliveryDate)).join('\n')}\n',
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
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: state.deliveryPointsCnt == 0 ? null : vm.closeDelivery,
          child: const Text('Завершить день')
        ),
      ),
    );
  }

  Widget _buildPaymentsCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();
    InfoState state = vm.state;

    return Card(
      child: ListTile(
        onTap: () => changePage(2),
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

  Widget _buildInfoCard(BuildContext context) {
    InfoViewModel vm = context.read<InfoViewModel>();

    return FutureBuilder(
      future: vm.state.user?.newVersionAvailable,
      builder: (context, snapshot) {
        if (!(snapshot.data ?? false)) return Container();

        return const Card(
          child: ListTile(
            isThreeLine: true,
            title: Text('Информация'),
            subtitle: Text('Доступна новая версия приложения'),
          )
        );
      }
    );
  }
}
