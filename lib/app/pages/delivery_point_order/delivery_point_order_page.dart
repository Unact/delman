import 'dart:async';

import 'package:collection/collection.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiver/core.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/accept_payment/accept_payment_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/pages/app/app_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

part 'delivery_point_order_state.dart';
part 'delivery_point_order_view_model.dart';

class DeliveryPointOrderPage extends StatelessWidget {
  final DeliveryPointOrder deliveryPointOrder;

  const DeliveryPointOrderPage({
    required this.deliveryPointOrder
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryPointOrderViewModel>(
      create: (context) => DeliveryPointOrderViewModel(
        context,
        deliveryPointOrder: deliveryPointOrder
      ),
      child: DeliveryPointOrderView(),
    );
  }
}

class DeliveryPointOrderView extends StatefulWidget {
  @override
  _DeliveryPointOrderViewState createState() => _DeliveryPointOrderViewState();
}

class _DeliveryPointOrderViewState extends State<DeliveryPointOrderView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Completer<void> _dialogCompleter = Completer();

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

  void showMessageAndCloseDialog(String message) {
    showMessage(message);
    closeDialog();
  }

  Future<void> showAddOrderInfoDialog(BuildContext context) async {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();
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
                vm.addComment(controller.text);
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
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();

    return await showDialog(
      context: context,
      builder: (_) => AcceptPaymentPage(
        deliveryPointOrder: vm.deliveryPointOrder,
        total: vm.total,
        cardPayment: vm.cardPayment
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

  void unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryPointOrderViewModel, DeliveryPointOrderState>(
      builder: (context, state) {
        DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ ${vm.order.trackingNumber}'),
            centerTitle: true
          ),
          persistentFooterButtons: [
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
            vm.deliveryPointOrder.isFinished ? null : TextButton(
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
      },
      listener: (context, state) async {
        DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();

        if (state is DeliveryPointOrderInProgress) {
          openDialog();
        } else if (state is DeliveryPointOrderPaymentStarted) {
          WidgetsBinding.instance!.addPostFrameCallback((_) async {
            vm.finishPayment(await showAcceptPaymentDialog());
          });
        } else if (state is DeliveryPointOrderFailure) {
          showMessageAndCloseDialog(state.message);
        } else if (state is DeliveryPointOrderCanceled) {
          showMessageAndCloseDialog(state.message);
        } else if (state is DeliveryPointOrderConfirmed) {
          showMessageAndCloseDialog(state.message);
        } else if (state is DeliveryPointOrderPaymentFinished) {
          showMessageAndCloseDialog(state.message);
        } else if (state is DeliveryPointOrderCommentAdded) {
          showMessageAndCloseDialog(state.message);
        } else if (state is DeliveryPointOrderNeedUserConfirmation) {
          state.confirmationCallback(await showConfirmationDialog(state.message));
        }
      },
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
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();

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
              !vm.orderLinesEditable ? Text(orderLine.factAmount.toString()) : SizedBox(
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