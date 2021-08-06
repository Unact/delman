import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/delivery_point_order_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/delivery_point_order_view_model.dart';
import 'package:delman/app/view_models/payments_view_model.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.paymentsPageName)
      ),
      body: Consumer<PaymentsViewModel>(
        builder: (context, vm, _) {
          return ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
            children: vm.payments.map((payment) {
              Order order = vm.getOrderForPayment(payment);
              DeliveryPointOrder deliveryPointOrder = vm.getDeliveryPointOrderForPayment(payment);

              return ListTile(
                isThreeLine: true,
                dense: true,
                title: Text('Заказ ${order.trackingNumber}', style: TextStyle(fontSize: 14.0)),
                contentPadding: EdgeInsets.all(0),
                subtitle: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Сумма: ${Format.numberStr(payment.summ)}\n',
                        style: TextStyle(fontSize: 12.0)
                      ),
                      TextSpan(
                        text: 'Оплата ${payment.isCard ? 'картой' : 'наличными'}\n',
                        style: TextStyle(fontSize: 12.0)
                      ),
                    ]
                  )
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ChangeNotifierProvider<DeliveryPointOrderViewModel>(
                        create: (context) => DeliveryPointOrderViewModel(
                          context: context,
                          deliveryPointOrder: deliveryPointOrder
                        ),
                        child: DeliveryPointOrderPage(),
                      )
                    )
                  );
                },
              );
            }).toList()
          );
        },
      )
    );
  }
}
