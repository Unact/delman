import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/delivery_point/delivery_point_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'delivery_state.dart';
part 'delivery_view_model.dart';

class DeliveryPage extends StatelessWidget {
  DeliveryPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryViewModel>(
      create: (context) => DeliveryViewModel(context),
      child: _DeliveryView(),
    );
  }
}

class _DeliveryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.deliveryPageName)
      ),
      body: BlocBuilder<DeliveryViewModel, DeliveryState>(
        builder: (context, state) {
          DeliveryViewModel vm = context.read<DeliveryViewModel>();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 24),
            children: vm.deliveries.map((e) => _deliveryTile(context, e)).expand((i) => i).toList()
          );
        }
      )
    );
  }

  List<Widget> _deliveryTile(BuildContext context, Delivery delivery) {
    DeliveryViewModel vm = context.read<DeliveryViewModel>();

    return [
      ListTile(
        dense: true,
        leading: Text('Маршрут от ${Format.dateStr(delivery.deliveryDate)}'),
      ),
      ...vm.getDeliveryPointsForDelivery(delivery).map((e) => _deliveryPointTile(context, e)).toList()
    ];
  }

  Widget _deliveryPointTile(BuildContext context, DeliveryPoint deliveryPoint) {
    Color color = deliveryPoint.isFinished ?
      Colors.green[400]! :
      (deliveryPoint.inProgress ? Colors.yellow[400]! : Colors.blue[400]!);

    return ListTile(
      leading: CircleAvatar(
        child: Text(deliveryPoint.seq.toString(), style: const TextStyle(color: Colors.black)),
        backgroundColor: color
      ),
      title: Text(deliveryPoint.addressName, style: const TextStyle(fontSize: 14.0)),
      subtitle: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '${Strings.planArrival}: ${Format.timeStr(deliveryPoint.planArrival)}\n',
              style: const TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
            TextSpan(
              text: '${Strings.factArrival}: ${Format.timeStr(deliveryPoint.factArrival)}\n',
              style: const TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
            TextSpan(
              text: '${Strings.factDeparture}: ${Format.timeStr(deliveryPoint.factDeparture)}\n',
              style: const TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
          ]
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => DeliveryPointPage(deliveryPoint: deliveryPoint)
          )
        );
      },
    );
  }
}
