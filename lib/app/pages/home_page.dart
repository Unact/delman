import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/pages/delivery_page.dart';
import 'package:delman/app/pages/info_page.dart';
import 'package:delman/app/pages/order_storages_page.dart';
import 'package:delman/app/pages/payments_page.dart';
import 'package:delman/app/view_models/delivery_view_model.dart';
import 'package:delman/app/view_models/home_view_model.dart';
import 'package:delman/app/view_models/info_view_model.dart';
import 'package:delman/app/view_models/order_storages_view_model.dart';
import 'package:delman/app/view_models/payments_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          bottomNavigationBar: _buildBottomNavigationBar(context, vm),
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<InfoViewModel>(
                create: (context) => InfoViewModel(context: context)
              ),
              ChangeNotifierProvider<DeliveryViewModel>(
                create: (context) => DeliveryViewModel(context: context)
              ),
              ChangeNotifierProvider<PaymentsViewModel>(
                create: (context) => PaymentsViewModel(context: context)
              ),
              ChangeNotifierProvider<OrderStoragesViewModel>(
                create: (context) => OrderStoragesViewModel(context: context)
              )
            ],
            child: [
              InfoPage(),
              DeliveryPage(),
              PaymentsPage(),
              OrderStoragesPage()
            ][vm.currentIndex]
          )
        );
      }
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, HomeViewModel vm) {
    return BottomNavigationBar(
      currentIndex: vm.currentIndex,
      onTap: vm.setCurrentIndex,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: Strings.infoPageName
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.departure_board),
          label: Strings.deliveryPageName
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: Strings.paymentsPageName
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: Strings.orderStoragesPageName
        )
      ],
    );
  }
}
