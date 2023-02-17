import 'dart:async';


import 'package:drift/drift.dart' show Value, TableUpdateQuery;
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/pages/accept_payment/accept_payment_page.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/utils/format.dart';
import '/app/utils/geo_loc.dart';
import '/app/utils/misc.dart';
import '/app/services/api.dart';
import '/app/widgets/widgets.dart';

part 'delivery_point_order_state.dart';
part 'delivery_point_order_view_model.dart';

class DeliveryPointOrderPage extends StatelessWidget {
  final DeliveryPointOrderExResult deliveryPointOrderEx;

  DeliveryPointOrderPage({
    Key? key,
    required this.deliveryPointOrderEx
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryPointOrderViewModel>(
      create: (context) => DeliveryPointOrderViewModel(
        context,
        deliveryPointOrderEx: deliveryPointOrderEx
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
  late final ProgressDialog _progressDialog = ProgressDialog(context: context);

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

  Future<void> showAcceptPaymentDialog() async {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();
    DeliveryPointOrderState state = vm.state;

    String result = await showDialog(
      context: context,
      builder: (_) => AcceptPaymentPage(
        deliveryPointOrderEx: vm.state.deliveryPointOrderEx,
        total: state.total,
        cardPayment: state.cardPayment
      ),
      barrierDismissible: false
    );

    vm.finishPayment(result);
  }

  Future<void> showConfirmationDialog(String message, Function callback) async {
    bool result = await showDialog<bool>(
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

    await callback(result);
  }

  Future<void> showAskPaymentDialog() async {
    Size size = MediaQuery.of(context).size;
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();
    DeliveryPointOrderState state = vm.state;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(top: 0, left: 24, bottom: 12),
          title: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                  iconSize: 24,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Column(
                children: const [
                  SizedBox(height: 24),
                  Text('Внимание'),
                ],
              )
            ]
          ),
          content: SizedBox(
            child: const Text('Хотите ли принять оплату?'),
            width: size.width
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                vm.tryStartPayment(false);
              },
              child: const Icon(Icons.account_balance_wallet),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
            !state.deliveryPointOrderEx.o.cardPaymentAllowed ? Container() : TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                vm.tryStartPayment(true);
              },
              child: const Icon(Icons.credit_card),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ]
        );
      }
    );
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
        bool isPickup = state.deliveryPointOrderEx.dpo.pickup;
        Order order = state.deliveryPointOrderEx.o;

        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ ${order.trackingNumber}'),
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
                    state.deliveryPointOrderEx.dpo.canceled ?
                      'Отменен' :
                      (state.deliveryPointOrderEx.dpo.finished ? 'Завершен' : 'Не завершен')
                  )
                ),
                InfoRow(
                  title: const Text('Посылка'),
                  trailing: Text(state.withCourier ? 'На борту' : 'Не на борту')
                ),
                InfoRow(
                  title: const Text('Возврат документов'),
                  trailing: Text(order.documentsReturn ? 'Да' : 'Нет')
                ),
                InfoRow(
                  title: const Text('Приемка'),
                  trailing: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: order.productArrivalName == null ?
                      [] :
                      [
                        IconButton(
                          icon: const Icon(Icons.qr_code_2),
                          onPressed: () => QRDialog(context: context, qr: order.productArrivalQR ?? '').open()
                        ),
                        Text(order.productArrivalName!)
                      ]
                  )
                ),
                InfoRow(title: const Text('ИМ'), trailing: Text(order.sellerName)),
                InfoRow(title: const Text('Номер в ИМ'), trailing: Text(order.number)),
                ...(isPickup ? _buildPickupRows(context) : _buildDeliveryRows(context)),
                ExpansionTile(
                  title: const Text('Служебная информация'),
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                  children: state.orderInfoLines.
                    map<Widget>((e) => _buildOrderInfoTile(context, e)).toList()..
                    add(
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          heightFactor: 0.75,
                          child: TextButton(
                            style: TextButton.styleFrom(foregroundColor: Colors.green),
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
        switch (state.status) {
          case DeliveryPointOrderStateStatus.paymentFinished:
          case DeliveryPointOrderStateStatus.commentAdded:
          case DeliveryPointOrderStateStatus.failure:
          case DeliveryPointOrderStateStatus.confirmed:
          case DeliveryPointOrderStateStatus.canceled:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            _progressDialog.close();
            break;
          case DeliveryPointOrderStateStatus.inProgress:
            await _progressDialog.open();
            break;
          case DeliveryPointOrderStateStatus.paymentStarted:
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await showAcceptPaymentDialog();
            });
            break;
          case DeliveryPointOrderStateStatus.askPaymentCollection:
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await showAskPaymentDialog();
            });
            break;
          case DeliveryPointOrderStateStatus.needUserConfirmation:
            await showConfirmationDialog(state.message, state.confirmationCallback);
            break;
          default:
        }
      },
    );
  }

  List<Widget> _buildPickupFooterButtons(BuildContext context) {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();
    DeliveryPointOrderState state = vm.state;
    DeliveryPointOrder deliveryPointOrder = state.deliveryPointOrderEx.dpo;

    return [
      deliveryPointOrder.finished ? null : TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
        child: const Text('Отменить'),
        onPressed: () {
          unfocus();
          vm.tryCancelOrder();
        }
      ),
      !state.isFinishable ? null : TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
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
    DeliveryPointOrderState state = vm.state;
    Order order = state.deliveryPointOrderEx.o;

    return [
      InfoRow(title: const Text('Отправитель'), trailing: Text(order.senderName ?? '')),
      InfoRow(
        title: const Text('Телефон'),
        trailing: GestureDetector(
          onTap: () => vm.callPhone(order.senderPhone),
          child: Text(order.senderPhone ?? '', style: const TextStyle(color: Colors.blue))
        )
      ),
      InfoRow(
        title: const Text('Погрузка'),
        trailing: Text(Format.timeStrFromInt(order.pickupLoadDuration))
      ),
      order.pickupDateTimeFrom == null ? Container() : InfoRow(
        title: const Text('Время забора'),
        trailing: Text(
          Format.timeStr(order.pickupDateTimeTo) + ' - ' + Format.timeStr(order.pickupDateTimeTo)
        )
      ),
      InfoRow(
        title: const Text('Забор'),
        trailing: ExpandingText(
          _formatTypeText(
            order.deliveryTypeName,
            order.senderElevator,
            order.senderFloor,
            order.senderFlat
          )
        )
      ),
      ExpansionTile(
        title: const Text('Позиции'),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        children: state.orderLines.map<Widget>((e) => _buildOrderLineTile(context, e, false)).toList()
      )
    ];
  }

  List<Widget> _buildDeliveryFooterButtons(BuildContext context) {
    DeliveryPointOrderViewModel vm = context.read<DeliveryPointOrderViewModel>();
    DeliveryPointOrderState state = vm.state;
    DeliveryPointOrder deliveryPointOrder = state.deliveryPointOrderEx.dpo;

    return [
      !state.needPayment ? null : TextButton(
        onPressed: () {
          unfocus();
          vm.tryStartPayment(false);
        },
        child: const Icon(Icons.account_balance_wallet),
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
      ),
      !state.needPayment || !state.deliveryPointOrderEx.o.cardPaymentAllowed ? null : TextButton(
        onPressed: () {
          unfocus();
          vm.tryStartPayment(true);
        },
        child: const Icon(Icons.credit_card),
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
      ),
      deliveryPointOrder.finished ? null : TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
        child: const Text('Отменить'),
        onPressed: () {
          unfocus();
          vm.tryCancelOrder();
        }
      ),
      !state.isFinishable ? null : TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
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
    DeliveryPointOrderState state = vm.state;
    Order order = state.deliveryPointOrderEx.o;

    return [
      InfoRow(
        title: const Text('Покупатель'),
        trailing: Text(order.buyerName ?? '')
      ),
      InfoRow(
        title: const Text('Телефон'),
        trailing: GestureDetector(
          onTap: () => vm.callPhone(order.buyerPhone),
          child: Text(order.buyerPhone ?? '', style: const TextStyle(color: Colors.blue))
        )
      ),
      InfoRow(
        title: const Text('Разгрузка'),
        trailing: Text(Format.timeStrFromInt(order.pickupLoadDuration))
      ),
      order.deliveryDateTimeFrom == null ? Container() : InfoRow(
        title: const Text('Время доставки'),
        trailing: Text(
          Format.timeStr(order.deliveryDateTimeFrom) + ' - ' + Format.timeStr(order.deliveryDateTimeTo)
        )
      ),
      InfoRow(
        title: const Text('Доставка'),
        trailing: ExpandingText(
          _formatTypeText(
            order.deliveryTypeName,
            order.buyerElevator,
            order.buyerFloor,
            order.buyerFlat
          )
        )
      ),
      InfoRow(title: const Text('Оплата'), trailing: Text(order.paymentTypeName)),
      InfoRow(title: const Text('Примечание'), trailing: ExpandingText(order.comment ?? '')),
      InfoRow(title: const Text('К оплате'), trailing: Text(Format.numberStr(state.total))),
      ExpansionTile(
        title: const Text('Позиции'),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        children: state.orderLines.map<Widget>(
          (e) => _buildOrderLineTile(context, e, state.isFinishable)
        ).toList()
      )
    ];
  }

  Widget _buildOrderInfoTile(BuildContext context, OrderInfoLine orderInfoLine) {
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
                child: ExpandingText(orderInfoLine.comment,
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
                  onChanged: (newValue) async => await vm.updateOrderLineAmount(orderLine, newValue),
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
