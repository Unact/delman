import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/pages/delivery_point/delivery_point_page.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/utils/format.dart';
import '/app/utils/styling.dart';

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
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 24),
            children: state.deliveries.map((e) => _deliveryTile(context, e)).expand((i) => i).toList()
          );
        }
      )
    );
  }

  List<Widget> _deliveryTile(BuildContext context, ExDelivery extendedDelivery) {
    return [
      ListTile(
        dense: true,
        leading: Text('Маршрут от ${Format.dateStr(extendedDelivery.delivery.deliveryDate)}'),
      ),
      ...extendedDelivery.deliveryPoints.map((e) => _deliveryPointTile(context, e)).toList()
    ];
  }

  Widget _deliveryPointTile(BuildContext context, DeliveryPointExResult deliveryPointEx) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Styling.deliveryPointColor(deliveryPointEx),
        child: Text(deliveryPointEx.dp.seq.toString(), style: const TextStyle(color: Colors.black))
      ),
      title: Text(deliveryPointEx.dp.addressName, style: const TextStyle(fontSize: 14.0)),
      subtitle: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '${Strings.planArrival}: ${Format.timeStr(deliveryPointEx.dp.planArrival)}\n',
              style: const TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
            TextSpan(
              text: '${Strings.factArrival}: ${Format.timeStr(deliveryPointEx.dp.factArrival)}\n',
              style: const TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
            TextSpan(
              text: '${Strings.factDeparture}: ${Format.timeStr(deliveryPointEx.dp.factDeparture)}\n',
              style: const TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
          ]
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => DeliveryPointPage(deliveryPointEx: deliveryPointEx)
          )
        );
      },
    );
  }
}
