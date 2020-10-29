import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/pages/person_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/info_view_model.dart';
import 'package:delman/app/view_models/person_view_model.dart';

class InfoPage extends StatefulWidget {
  InfoPage({Key key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  InfoViewModel _infoViewModel;
  Completer<void> _refresherCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _infoViewModel = context.read<InfoViewModel>();
    _infoViewModel.addListener(this.vmListener);

    if (_infoViewModel.needRefresh) openRefresher();
  }

  @override
  void dispose() {
    _infoViewModel.removeListener(this.vmListener);
    super.dispose();
  }

  Future<void> openRefresher() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState.show();
    });
  }

  void closeRefresher() {
    _refresherCompleter.complete();
    _refresherCompleter = Completer();
  }

  Future<void> vmListener() async {
    switch (_infoViewModel.state) {
      case InfoState.Failure:
      case InfoState.DataLoaded:
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(_infoViewModel.message)));
        closeRefresher();

        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                  builder: (BuildContext context) => ChangeNotifierProvider<PersonViewModel>(
                    create: (context) => PersonViewModel(context: context),
                    child: PersonPage(),
                  ),
                  fullscreenDialog: true
                )
              );
            }
          )
        ]
      ),
      body: Consumer<InfoViewModel>(builder: (context, vm, _) {
        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            vm.getData();
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
      })
    );
  }

  List<Widget> _buildInfoCards(BuildContext context) {
    InfoViewModel vm = Provider.of<InfoViewModel>(context);

    return <Widget>[
      Card(
        child: ListTile(
          onTap: () => vm.changePage(1),
          isThreeLine: true,
          title: Text(Strings.deliveryPageName),
          subtitle: _buildDeliveriesCard(context),
        ),
      ),
      Card(
        child: ListTile(
          onTap: () => vm.changePage(2),
          isThreeLine: true,
          title: Text(Strings.paymentsPageName),
          subtitle: _buildPaymentsCard(context),
        ),
      ),
      _buildInfoCard(context),
    ];
  }

  Widget _buildDeliveriesCard(BuildContext context) {
    InfoViewModel vm = Provider.of<InfoViewModel>(context);

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.grey),
        children: <TextSpan>[
          TextSpan(text: 'Точек: ${vm.deliveryPointsCnt}\n', style: TextStyle(fontSize: 12.0)),
          TextSpan(text: 'Осталось: ${vm.deliveryPointsLeftCnt}\n', style: TextStyle(fontSize: 12.0))
        ]
      )
    );
  }

  Widget _buildPaymentsCard(BuildContext context) {
    InfoViewModel vm = Provider.of<InfoViewModel>(context);

    return RichText(
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
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    InfoViewModel vm = Provider.of<InfoViewModel>(context);

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
