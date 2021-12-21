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

  DeliveryPointOrderPage({
    Key? key,
    required this.deliveryPointOrder
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryPointOrderViewModel>(
      create: (context) => DeliveryPointOrderViewModel(
        context,
        deliveryPointOrder: deliveryPointOrder
      ),
      child: _DeliveryPointOrderView(),
    );
  }
}

class _DeliveryPointOrderView extends StatefulWidget {
  @override
  _DeliveryPointOrderViewState createState() => _DeliveryPointOrderViewState();
}

class _DeliveryPointOrderViewState extends State<_DeliveryPointOrderView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Completer<void> _dialogCompleter = Completer();

  Future<void> openDialog() async {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
          title: const Text('Комментарий'),
          content: SizedBox(
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
              child: const Text('Сохранить')
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отменить')
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
          title: const Text('Предупреждение'),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Text(message)])),
          actions: <Widget>[
            TextButton(child: const Text(Strings.ok), onPressed: () => Navigator.of(context).pop(true)),
            TextButton(child: const Text(Strings.cancel), onPressed: () => Navigator.of(context).pop(false))
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
        bool isPickup = vm.deliveryPointOrder.isPickup;

        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ ${vm.order.trackingNumber}'),
            centerTitle: true
          ),
          persistentFooterButtons: isPickup ? _buildPickupFooterButtons(context) : _buildDeliveryFooterButtons(context),
          body: Form(
            key: _formKey,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              children: [
                InfoRow(
                  title: const Text('Статус'),
                  trailing: Text(
                    vm.deliveryPointOrder.isCanceled ?
                      'Отменен' :
                      (vm.deliveryPointOrder.isFinished ? 'Завершен' : 'Не завершен')
                  )
                ),
                InfoRow(
                  title: const Text('Посылка'),
                  trailing: Text(vm.withCourier ? 'На борту' : 'Не на борту')
                ),
                InfoRow(
                  title: const Text('Возврат документов'),
                  trailing: Text(vm.order.needDocumentsReturn ? 'Да' : 'Нет')
                ),
                InfoRow(title: const Text('ИМ'), trailing: Text(vm.order.sellerName)),
                InfoRow(title: const Text('Номер в ИМ'), trailing: Text(vm.order.number)),
                ...(isPickup ? _buildPickupRows(context) : _buildDeliveryRows(context)),
                ExpansionTile(
                  title: const Text('Служебная информация'),
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                  children: vm.sortedOrderInfoList.
                    map<Widget>((e) => _buildOrderInfoTile(context, e)).toList()..
                    add(
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          heightFactor: 0.75,
                          child: TextButton(
                            style: TextButton.styleFrom(primary: Colors.green),
                            onPressed: () => showAddOrderInfoDialog(context),
                            child: const Text('Добавить')
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

  List<Widget> _buildPickupFooterButtons(BuildContext context) {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();

    return [
      vm.deliveryPointOrder.isFinished ? null : TextButton(
        style: TextButton.styleFrom(primary: Colors.redAccent),
        child: const Text('Отменить'),
        onPressed: () {
          unfocus();
          vm.tryCancelOrder();
        }
      ),
      vm.deliveryPointOrder.isFinished || !vm.deliveryPoint.inProgress ? null : TextButton(
        style: TextButton.styleFrom(primary: Colors.redAccent),
        child: const Text('Завершить'),
        onPressed: () {
          unfocus();
          vm.tryConfirmOrder();
        }
      ),
    ].whereType<Widget>().toList();
  }

  List<Widget> _buildPickupRows(BuildContext context) {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();

    return [
      InfoRow(title: const Text('Отправитель'), trailing: Text(vm.order.senderName ?? '')),
      InfoRow(
        title: const Text('Телефон'),
        trailing: GestureDetector(
          onTap: () => vm.callPhone(vm.order.senderPhone),
          child: Text(vm.order.senderPhone ?? '', style: const TextStyle(color: Colors.blue))
        )
      ),
      vm.order.pickupDateTimeFrom == null ? Container() : InfoRow(
        title: const Text('Время забора'),
        trailing: Text(
          Format.timeStr(vm.order.pickupDateTimeTo) + ' - ' + Format.timeStr(vm.order.pickupDateTimeTo)
        )
      ),
      InfoRow(
        title: const Text('Забор'),
        trailing: ExpandingText(
          _formatTypeText(
            vm.order.deliveryTypeName,
            vm.order.hasSenderElevator,
            vm.order.senderFloor,
            vm.order.senderFlat
          )
        )
      ),
      ExpansionTile(
        title: const Text('Позиции'),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        children: vm.sortedOrderLines.map<Widget>((e) => _buildOrderLineTile(context, e, false)).toList()
      )
    ];
  }

  List<Widget> _buildDeliveryFooterButtons(BuildContext context) {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();
    bool totalEditable = vm.deliveryPointOrder.isFinished &&
      !vm.deliveryPointOrder.isCanceled &&
      vm.payment == null &&
      vm.total != 0;

    return [
      !totalEditable ? null : TextButton(
        onPressed: () {
          unfocus();
          vm.tryStartPayment(false);
        },
        child: const Icon(Icons.account_balance_wallet),
        style: TextButton.styleFrom(primary: Colors.redAccent),
      ),
      !totalEditable || !vm.order.isCardPaymentAllowed ? null : TextButton(
        onPressed: () {
          unfocus();
          vm.tryStartPayment(true);
        },
        child: const Icon(Icons.credit_card),
        style: TextButton.styleFrom(primary: Colors.redAccent),
      ),
      vm.deliveryPointOrder.isFinished ? null : TextButton(
        style: TextButton.styleFrom(primary: Colors.redAccent),
        child: const Text('Отменить'),
        onPressed: () {
          unfocus();
          vm.tryCancelOrder();
        }
      ),
      vm.deliveryPointOrder.isFinished || !vm.deliveryPoint.inProgress ? null : TextButton(
        style: TextButton.styleFrom(primary: Colors.redAccent),
        child: const Text('Завершить'),
        onPressed: () {
          unfocus();
          vm.tryConfirmOrder();
        }
      ),
    ].whereType<Widget>().toList();
  }

  List<Widget> _buildDeliveryRows(BuildContext context) {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();

    return [
      InfoRow(
        title: const Text('Покупатель'),
        trailing: Text(vm.order.buyerName ?? '')
      ),
      InfoRow(
        title: const Text('Телефон'),
        trailing: GestureDetector(
          onTap: () => vm.callPhone(vm.order.buyerPhone),
          child: Text(vm.order.buyerPhone ?? '', style: const TextStyle(color: Colors.blue))
        )
      ),
      vm.order.deliveryDateTimeFrom == null ? Container() : InfoRow(
        title: const Text('Время доставки'),
        trailing: Text(
          Format.timeStr(vm.order.deliveryDateTimeFrom) + ' - ' + Format.timeStr(vm.order.deliveryDateTimeTo)
        )
      ),
      InfoRow(
        title: const Text('Доставка'),
        trailing: ExpandingText(
          _formatTypeText(
            vm.order.deliveryTypeName,
            vm.order.hasBuyerElevator,
            vm.order.buyerFloor,
            vm.order.buyerFlat
          )
        )
      ),
      InfoRow(title: const Text('Оплата'), trailing: Text(vm.order.paymentTypeName)),
      InfoRow(title: const Text('Примечание'), trailing: ExpandingText(vm.order.comment ?? '')),
      InfoRow(title: const Text('К оплате'), trailing: Text(Format.numberStr(vm.total))),
      ExpansionTile(
        title: const Text('Позиции'),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        children: vm.sortedOrderLines.map<Widget>(
          (e) => _buildOrderLineTile(context, e, !vm.deliveryPointOrder.isFinished)
        ).toList()
      )
    ];
  }

  Widget _buildOrderInfoTile(BuildContext context, OrderInfo orderInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SizedBox(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExpandingText(orderInfo.comment,
                  textAlign: TextAlign.left, style: const TextStyle(fontSize: 12)
                ),
              )
            )
          ),
        ]
      ),
    );
  }

  Widget _buildOrderLineTile(BuildContext context, OrderLine orderLine, bool editable) {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SizedBox(
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExpandingText(orderLine.name, textAlign: TextAlign.left, style: const TextStyle(fontSize: 12)),
              )
            )
          ),
          Row(
            children: <Widget>[
              Text(Format.numberStr(orderLine.price) + ' x '),
              !editable ? Text(orderLine.factAmount.toString()) : SizedBox(
                width: 40,
                height: 36,
                child: TextFormField(
                  initialValue: orderLine.factAmount?.toString(),
                  textAlign: TextAlign.center,
                  onChanged: (newValue) => vm.updateOrderLineAmount(orderLine, newValue),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 12)
                  ),
                )
              )
            ],
          )
        ]
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  String _formatTypeText(String typeName, bool hasElevator, int? floor, String? flat) {
    return typeName + (hasElevator ? '\nлифт' : '\nпешком') +
      (floor == null ? '' : '\nэтаж ' + floor.toString()) +
      (flat == null ? '' : ' квартира ' + flat.toString());
  }
}
