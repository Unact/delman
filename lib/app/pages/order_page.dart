import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/accept_payment_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/accept_payment_view_model.dart';
import 'package:delman/app/view_models/order_view_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  OrderViewModel _orderViewModel;
  Completer<void> _dialogCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _orderViewModel = context.read<OrderViewModel>();
    _orderViewModel.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _orderViewModel.removeListener(this.vmListener);
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
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String> showAcceptPaymentDialog() async {
    return await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider<AcceptPaymentViewModel>(
        create: (context) => AcceptPaymentViewModel(
          context: context,
          order: _orderViewModel.order,
          total: _orderViewModel.total,
          cardPayment: _orderViewModel.cardPayment
        ),
        child: AcceptPaymentPage(),
      ),
      barrierDismissible: false
    );
  }

  Future<bool> showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Предупреждение'),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Text('Заказ не оплачен!')])),
          actions: <Widget>[
            FlatButton(child: Text(Strings.ok), onPressed: () => Navigator.of(context).pop(true)),
            FlatButton(child: Text(Strings.cancel), onPressed: () => Navigator.of(context).pop(false))
          ],
        );
      }
    );
  }

  Future<void> vmListener() async {
    switch (_orderViewModel.state) {
      case OrderState.InProgress:
        openDialog();
        break;
      case OrderState.PaymentStarted:
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _orderViewModel.finishPayment(await showAcceptPaymentDialog());
        });
        break;
      case OrderState.Failure:
      case OrderState.Canceled:
      case OrderState.PaymentFinished:
      case OrderState.Confirmed:
        showMessage(_orderViewModel.message);
        closeDialog();
        break;
      case OrderState.NeedUserConfirmation:
        _orderViewModel.confirmOrder(await showConfirmationDialog());
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
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Заказ ${vm.order.trackingNumber}'),
            centerTitle: true
          ),
          persistentFooterButtons: vm.order.isFinished ? null : <Widget>[
            FlatButton(
              child: Text('Отменить'),
              onPressed: () {
                unfocus();
                vm.cancelOrder();
              }
            ),
            FlatButton(
              child: Text('Завершить'),
              onPressed: () {
                unfocus();
                vm.tryConfirmOrder();
              }
            ),
          ],
          body: Form(
            key: _formKey,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 24, bottom: 24),
              children: [
                ListTile(
                  leading: Text('Статус'),
                  trailing: Text(
                    vm.order.isCanceled ?
                      'Отменен' :
                      (vm.order.isFinished ? 'Доставлен' : 'Ожидает доставки')
                  ),
                  dense: true
                ),
                ListTile(
                  leading: Text('ИМ'),
                  trailing: Text(vm.order.sellerName),
                  dense: true
                ),
                ListTile(
                  leading: Text('Номер в ИМ'),
                  trailing: Text(vm.order.number),
                  dense: true
                ),
                ListTile(
                  leading: Text('Покупатель'),
                  trailing: Text(vm.order.buyerName),
                  dense: true
                ),
                ListTile(
                  leading: Text('Телефон'),
                  trailing: GestureDetector(onTap: vm.callPhone, child: Text(vm.order.phone ?? '')),
                  dense: true
                ),
                vm.order.deliveryFrom == null ? Container() : ListTile(
                  leading: Text('Время доставки'),
                  trailing: Text(Format.timeStr(vm.order.deliveryFrom) + ' - ' + Format.timeStr(vm.order.deliveryTo)),
                  dense: true
                ),
                ListTile(
                  leading: Text('Доставка'),
                  trailing: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: '${vm.order.deliveryTypeName} (',
                          style: TextStyle(color: Colors.black, fontSize: 14.0)
                        ),
                        TextSpan(
                          text: '${vm.order.hasElevator ? 'лифт' : 'пешком'}',
                          style: TextStyle(color: Colors.black, fontSize: 14.0)
                        ),
                        vm.order.floor == null ? TextSpan() : TextSpan(
                          text: ', этаж ${vm.order.floor}',
                          style: TextStyle(color: Colors.black, fontSize: 14.0)
                        ),
                        vm.order.flat == null ? TextSpan() : TextSpan(
                          text: ', квартира ${vm.order.flat}',
                          style: TextStyle(color: Colors.black, fontSize: 14.0)
                        ),
                        TextSpan(
                          text: ')',
                          style: TextStyle(color: Colors.black, fontSize: 14.0)
                        )
                      ]
                    )
                  ),
                  dense: true
                ),
                ListTile(
                  leading: Text('Оплата'),
                  trailing: Text(vm.order.paymentTypeName),
                  dense: true
                ),
                ListTile(
                  leading: Text('Примечание'),
                  trailing: Text(vm.order.comment ?? ''),
                  dense: true
                ),
                ListTile(
                  leading: Text('К оплате'),
                  trailing: !vm.totalEditable ? Text(Format.numberStr(vm.total)) : null,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      !vm.totalEditable ? Container() : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 36,
                            child: TextField(
                              textAlign: TextAlign.end,
                              controller: TextEditingController(text: Format.numberStr(vm.total, true)),
                              onChanged: vm.updateTotal,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              maxLines: 1,
                              style: TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 12, left: 8.0, right: 8.0),
                                hintText: Format.numberStr(vm.total)
                              )
                            )
                          ),
                          SizedBox(
                            width: 52,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(18))
                              ),
                              onPressed: () {
                                unfocus();
                                vm.startPayment(false);
                              },
                              child: Icon(Icons.account_balance_wallet),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            )
                          ),
                          SizedBox(
                            width: 52,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(18))
                              ),
                              onPressed: () {
                                unfocus();
                                vm.startPayment(true);
                              },
                              child: Icon(Icons.credit_card),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            )
                          ),
                        ]
                      ),
                    ]
                  ),
                ),
                ExpansionTile(
                  title: Text('Позиции'),
                  initiallyExpanded: true,
                  children: vm.sortedOrderLines.map<Widget>((e) => _buildOrderLineTile(context, e)).toList()
                    ..add(Divider(height: 1, indent: 32))
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
          Text(orderLine.name),
          Row(
            children: <Widget>[
              Text(Format.numberStr(orderLine.price) + ' x '),
              vm.order.isFinished ? Text(orderLine.factAmount.toString()) : SizedBox(
                width: 40,
                height: 36,
                child: TextFormField(
                  initialValue: orderLine.factAmount?.toString(),
                  textAlign: TextAlign.center,
                  onChanged: (newValue) => vm.updateOrderLineAmount(orderLine, newValue),
                  keyboardType: TextInputType.number,
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
      contentPadding: EdgeInsets.only(left: 32, right: 16),
    );
  }
}
