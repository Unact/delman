import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/data/database.dart';
import '/app/constants/strings.dart';
import '/app/pages/delivery_point_order/delivery_point_order_page.dart';
import '/app/pages/shared/page_view_model.dart';

part 'payments_state.dart';
part 'payments_view_model.dart';

class PaymentsPage extends StatelessWidget {
  PaymentsPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentsViewModel>(
      create: (context) => PaymentsViewModel(context),
      child: _PaymentsView(),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.paymentsPageName)
      ),
      body: BlocBuilder<PaymentsViewModel, PaymentsState>(
        builder: (context, state) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
            children: state.exPayments.map((exPayment) {

              return ListTile(
                isThreeLine: true,
                dense: true,
                title: Text(
                  'Заказ ${exPayment.deliveryPointOrderEx.o.trackingNumber}',
                  style: const TextStyle(fontSize: 14.0)
                ),
                contentPadding: const EdgeInsets.all(0),
                subtitle: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.grey),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Сумма: ${Format.numberStr(exPayment.payment.summ)}\n',
                        style: const TextStyle(fontSize: 12.0)
                      ),
                      TextSpan(
                        text: 'Оплата ${exPayment.payment.transactionId != null ? 'картой' : 'наличными'}\n',
                        style: const TextStyle(fontSize: 12.0)
                      ),
                    ]
                  )
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => DeliveryPointOrderPage(
                        deliveryPointOrderEx: exPayment.deliveryPointOrderEx
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
