import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/accept_payment_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/accept_payment_view_model.dart';
import 'package:delman/app/view_models/order_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  OrderViewModel? _orderViewModel;
  Completer<void> _dialogCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _orderViewModel = context.read<OrderViewModel>();
    _orderViewModel!.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _orderViewModel!.removeListener(this.vmListener);
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String> showAcceptPaymentDialog() async {
    return await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider<AcceptPaymentViewModel>(
        create: (context) => AcceptPaymentViewModel(
          context: context,
          order: _orderViewModel!.order,
          total: _orderViewModel!.total,
          cardPayment: _orderViewModel!.cardPayment
        ),
        child: AcceptPaymentPage(),
      ),
      barrierDismissible: false
    );
  }

  Future<bool> showConfirmationDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Предупреждение'),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Text(message)])),
          actions: <Widget>[
            TextButton(child: Text(Strings.ok), onPressed: () => Navigator.of(context).pop(true)),
            TextButton(child: Text(Strings.cancel), onPressed: () => Navigator.of(context).pop(false))
          ],
        );
      }
    ) ?? false;
  }

  Future<void> vmListener() async {
    switch (_orderViewModel!.state) {
      case OrderState.InProgress:
        openDialog();
        break;
      case OrderState.PaymentStarted:
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          _orderViewModel!.finishPayment(await showAcceptPaymentDialog());
        });
        break;
      case OrderState.Failure:
      case OrderState.Canceled:
      case OrderState.PaymentFinished:
      case OrderState.Confirmed:
        showMessage(_orderViewModel!.message!);
        closeDialog();
        break;
      case OrderState.NeedUserConfirmation:
        _orderViewModel!.confirmationCallback!(await showConfirmationDialog(_orderViewModel!.message!));
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
    return Consumer<OrderViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ ${vm.order.trackingNumber}'),
            centerTitle: true
          ),
          persistentFooterButtons: vm.order.isFinished ? null : [
            !vm.totalEditable ? null : TextButton(
              onPressed: () {
                unfocus();
                vm.tryStartPayment(false);
              },
              child: Icon(Icons.account_balance_wallet),
              style: TextButton.styleFrom(primary: Colors.redAccent),
            ),
            !vm.totalEditable || !vm.order.isCardPaymentAllowed ? null : TextButton(
              onPressed: () {
                unfocus();
                vm.tryStartPayment(true);
              },
              child: Icon(Icons.credit_card),
              style: TextButton.styleFrom(primary: Colors.redAccent),
            ),
            TextButton(
              style: TextButton.styleFrom(primary: Colors.redAccent),
              child: Text('Отменить'),
              onPressed: () {
                unfocus();
                vm.tryCancelOrder();
              }
            ),
            !vm.isInProgress ? null : TextButton(
              style: TextButton.styleFrom(primary: Colors.redAccent),
              child: Text('Завершить'),
              onPressed: () {
                unfocus();
                vm.tryConfirmOrder();
              }
            ),
          ].whereType<Widget>().toList(),
          body: Form(
            key: _formKey,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 24, bottom: 24),
              children: [
                InfoRow(
                  title: Text('Статус'),
                  trailing: Text(vm.orderStatus)
                ),
                InfoRow(
                  title: Text('Посылка'),
                  trailing: Text(vm.withCourier ? 'На борту' : 'Не на борту')
                ),
                InfoRow(title: Text('ИМ'), trailing: Text(vm.order.sellerName)),
                InfoRow(title: Text('Номер в ИМ'), trailing: Text(vm.order.number)),
                InfoRow(
                  title: Text(vm.order.isPickup ? 'Отправитель' : 'Покупатель'),
                  trailing: Text(vm.order.personName ?? '')
                ),
                InfoRow(
                  title: Text('Телефон'),
                  trailing: GestureDetector(
                    onTap: vm.callPhone,
                    child: Text(vm.order.phone ?? '', style: TextStyle(color: Colors.blue))
                  )
                ),
                vm.order.timeFrom == null ? Container() : InfoRow(
                  title: Text('Время ${vm.order.isPickup ? 'забора' : 'доставки'}'),
                  trailing: Text(Format.timeStr(vm.order.timeFrom) + ' - ' + Format.timeStr(vm.order.timeTo))
                ),
                InfoRow(
                  title: Text(vm.order.isPickup ? 'Забор' : 'Доставка'),
                  trailing: ExpandingText(
                    vm.order.deliveryTypeName +
                      (vm.order.hasElevator ? '\nлифт' : '\nпешком') +
                      (vm.order.floor == null ? '' : '\nэтаж ' + vm.order.floor.toString())+
                      (vm.order.flat == null ? '' : ' квартира ' + vm.order.flat.toString())
                  )
                ),
                vm.order.isPickup ?
                  Container() :
                  InfoRow(title: Text('Оплата'), trailing: Text(vm.order.paymentTypeName)),
                vm.order.isPickup ?
                  Container() :
                  InfoRow(title: Text('Примечание'), trailing: ExpandingText(vm.order.comment ?? '')),
                vm.order.isPickup ?
                  Container() :
                  InfoRow(title: Text('К оплате'), trailing: Text(Format.numberStr(vm.total))),
                ExpansionTile(
                  title: Text('Позиции'),
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.symmetric(horizontal: 8),
                  children: vm.sortedOrderLines.map<Widget>((e) => _buildOrderLineTile(context, e)).toList()
                ),
              ],
            )
          )
        );
      }
    );
  }

  Widget _buildOrderLineTile(BuildContext context, OrderLine orderLine) {
    OrderViewModel vm = Provider.of<OrderViewModel>(context);

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExpandingText(orderLine.name, textAlign: TextAlign.left, style: TextStyle(fontSize: 12)),
              )
            )
          ),
          Row(
            children: <Widget>[
              Text(Format.numberStr(orderLine.price) + ' x '),
              !vm.isInProgress || vm.order.isPickup ? Text(orderLine.factAmount.toString()) : SizedBox(
                width: 40,
                height: 36,
                child: TextFormField(
                  initialValue: orderLine.factAmount?.toString(),
                  textAlign: TextAlign.center,
                  onChanged: (newValue) => vm.updateOrderLineAmount(orderLine, newValue),
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 12)
                  ),
                )
              )
            ],
          )
        ]
      ),
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
