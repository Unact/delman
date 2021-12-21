import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/pages/delivery/delivery_page.dart';
import 'package:delman/app/pages/info/info_page.dart';
import 'package:delman/app/pages/order_storages/order_storages_page.dart';
import 'package:delman/app/pages/payments/payments_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'home_state.dart';
part 'home_view_model.dart';

class HomePage extends StatelessWidget {
  HomePage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeViewModel>(
      create: (context) => HomeViewModel(context),
      child: _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeState>(
      builder: (context, state) {
        HomeViewModel vm = context.read<HomeViewModel>();

        return Scaffold(
          bottomNavigationBar: _buildBottomNavigationBar(context),
          body: [
            InfoPage(),
            DeliveryPage(),
            PaymentsPage(),
            OrderStoragesPage()
          ][vm.currentIndex]
        );
      }
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    HomeViewModel vm = context.read<HomeViewModel>();

    return BottomNavigationBar(
      currentIndex: vm.currentIndex,
      onTap: vm.setCurrentIndex,
      type: BottomNavigationBarType.fixed,
      items: const [
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
