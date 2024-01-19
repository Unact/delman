import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/data/database.dart';
import '/app/constants/strings.dart';
import '/app/entities/entities.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/repositories/orders_repository.dart';

part 'order_qr_scan_state.dart';
part 'order_qr_scan_view_model.dart';

class OrderQRScanPage extends StatelessWidget {
  OrderQRScanPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderQRScanViewModel>(
      create: (context) => OrderQRScanViewModel(
        RepositoryProvider.of<OrdersRepository>(context),
      ),
      child: _OrderQRScanView(),
    );
  }
}

class _OrderQRScanView extends StatefulWidget {
  @override
  _OrderQRScanViewState createState() => _OrderQRScanViewState();
}

class _OrderQRScanViewState extends State<_OrderQRScanView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderQRScanViewModel, OrderQRScanState>(
      builder: (context, state) {
        OrderQRScanViewModel vm = context.read<OrderQRScanViewModel>();

        return ScanView(
          onRead: vm.readQRCode,
          child: _buildOrderInfo(context),
        );
      },
      listener: (context, state) async {
        switch (state.status) {
          case OrderQRScanStateStatus.failure:
            Misc.showMessage(context, state.message);
            break;
          case OrderQRScanStateStatus.finished:
            Navigator.of(context).pop(state.order!);
            break;
          default:
        }
      }
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    OrderQRScanViewModel vm = context.read<OrderQRScanViewModel>();

    if (vm.state.status == OrderQRScanStateStatus.scanReadStarted) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (vm.state.order == null) return Container();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Заказ ${vm.state.order!.trackingNumber}',
            style: const TextStyle(color: Colors.white, fontSize: 20)
          )
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Мест ${vm.state.orderPackageScanned.where((el) => el).length}/${vm.state.order!.packages}',
            style: const TextStyle(color: Colors.white, fontSize: 20)
          )
        )
      ]
    );
  }
}
