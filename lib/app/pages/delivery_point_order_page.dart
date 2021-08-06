import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/accept_payment_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/accept_payment_view_model.dart';
import 'package:delman/app/view_models/delivery_point_order_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

class DeliveryPointOrderPage extends StatefulWidget {
  const DeliveryPointOrderPage({Key? key}) : super(key: key);

  @override
  _DeliveryPointOrderPageState createState() => _DeliveryPointOrderPageState();
}

class _DeliveryPointOrderPageState extends State<DeliveryPointOrderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DeliveryPointOrderViewModel? _deliveryPointOrderViewModel;
  Completer<void> _dialogCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _deliveryPointOrderViewModel = context.read<DeliveryPointOrderViewModel>();
    _deliveryPointOrderViewModel!.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _deliveryPointOrderViewModel!.removeListener(this.vmListener);
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
    if (message == '') return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> showAddOrderInfoDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    Size size = MediaQuery.of(context).size;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Комментарий'),
          content: Container(
            child: TextField(
              textCapitalization: TextCapitalization.words,
              controller: controller,
            ),
            width: size.width
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deliveryPointOrderViewModel!.addComment(controller.text);
              },
              child: Text('Сохранить')
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отменить')
            )
          ]
        );
      }
    );
  }

  Future<String> showAcceptPaymentDialog() async {
    return await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider<AcceptPaymentViewModel>(
        create: (context) => AcceptPaymentViewModel(
          context: context,
          order: _deliveryPointOrderViewModel!.order,
          total: _deliveryPointOrderViewModel!.total,
          cardPayment: _deliveryPointOrderViewModel!.cardPayment
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
    switch (_deliveryPointOrderViewModel!.state) {
      case DeliveryPointOrderState.InProgress:
        openDialog();
        break;
      case DeliveryPointOrderState.PaymentStarted:
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          _deliveryPointOrderViewModel!.finishPayment(await showAcceptPaymentDialog());
        });
        break;
      case DeliveryPointOrderState.Failure:
      case DeliveryPointOrderState.Canceled:
      case DeliveryPointOrderState.PaymentFinished:
      case DeliveryPointOrderState.Confirmed:
      case DeliveryPointOrderState.OrderInfoCommentAdded:
        showMessage(_deliveryPointOrderViewModel!.message!);
        closeDialog();
        break;
      case DeliveryPointOrderState.NeedUserConfirmation:
        _deliveryPointOrderViewModel!.confirmationCallback!(
          await showConfirmationDialog(_deliveryPointOrderViewModel!.message!)
        );
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
    return Consumer<DeliveryPointOrderViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ ${vm.order.trackingNumber}'),
            centerTitle: true
          ),
          persistentFooterButtons: vm.deliveryPointOrder.isFinished ? null : [
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
                InfoRow(
                  title: Text('Возврат документов'),
                  trailing: Text(vm.order.needDocumentsReturn ? 'Да' : 'Нет')
                ),
                InfoRow(title: Text('ИМ'), trailing: Text(vm.order.sellerName)),
                InfoRow(title: Text('Номер в ИМ'), trailing: Text(vm.order.number)),
                InfoRow(
                  title: Text(vm.deliveryPointOrder.isPickup ? 'Отправитель' : 'Покупатель'),
                  trailing: Text(vm.personName ?? '')
                ),
                InfoRow(
                  title: Text('Телефон'),
                  trailing: GestureDetector(
                    onTap: vm.callPhone,
                    child: Text(vm.phone ?? '', style: TextStyle(color: Colors.blue))
                  )
                ),
                vm.dateTimeFrom == null ? Container() : InfoRow(
                  title: Text('Время ${vm.deliveryPointOrder.isPickup ? 'забора' : 'доставки'}'),
                  trailing: Text(Format.timeStr(vm.dateTimeFrom) + ' - ' + Format.timeStr(vm.dateTimeTo))
                ),
                InfoRow(
                  title: Text(vm.deliveryPointOrder.isPickup ? 'Забор' : 'Доставка'),
                  trailing: ExpandingText(
                    vm.order.deliveryTypeName +
                      (vm.hasElevator ? '\nлифт' : '\nпешком') +
                      (vm.floor == null ? '' : '\nэтаж ' + vm.floor.toString())+
                      (vm.flat == null ? '' : ' квартира ' + vm.flat.toString())
                  )
                ),
                vm.deliveryPointOrder.isPickup ?
                  Container() :
                  InfoRow(title: Text('Оплата'), trailing: Text(vm.order.paymentTypeName)),
                vm.deliveryPointOrder.isPickup ?
                  Container() :
                  InfoRow(title: Text('Примечание'), trailing: ExpandingText(vm.order.comment ?? '')),
                vm.deliveryPointOrder.isPickup ?
                  Container() :
                  InfoRow(title: Text('К оплате'), trailing: Text(Format.numberStr(vm.total))),
                ExpansionTile(
                  title: Text('Позиции'),
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.symmetric(horizontal: 8),
                  children: vm.sortedOrderLines.map<Widget>((e) => _buildOrderLineTile(context, e)).toList()
                ),
                ExpansionTile(
                  title: Text('Служебная информация'),
                  initiallyExpanded: false,
                  tilePadding: EdgeInsets.symmetric(horizontal: 8),
                  children: vm.sortedOrderInfoList.
                    map<Widget>((e) => _buildOrderInfoTile(context, e)).toList()..
                    add(
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          heightFactor: 0.75,
                          child: TextButton(
                            style: TextButton.styleFrom(primary: Colors.green),
                            onPressed: () => showAddOrderInfoDialog(context),
                            child: Text('Добавить')
                          )
                        )
                      )
                    )
                ),
              ],
            )
          )
        );
      }
    );
  }

  Widget _buildOrderInfoTile(BuildContext context, OrderInfo orderInfo) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExpandingText(orderInfo.comment, textAlign: TextAlign.left, style: TextStyle(fontSize: 12)),
              )
            )
          ),
        ]
      ),
    );
  }

  Widget _buildOrderLineTile(BuildContext context, OrderLine orderLine) {
    DeliveryPointOrderViewModel vm = Provider.of<DeliveryPointOrderViewModel>(context);

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
              !vm.isInProgress || vm.deliveryPointOrder.isPickup ? Text(orderLine.factAmount.toString()) : SizedBox(
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
