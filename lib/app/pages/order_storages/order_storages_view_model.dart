part of 'order_storages_page.dart';

class OrderStoragesViewModel extends PageViewModel<OrderStoragesState> {
  OrderStoragesViewModel(BuildContext context) : super(context, OrderStoragesInitial());

  List<OrderStorage> get orderStorages {
    return appViewModel.orderStorages.where((e) => e.id != appViewModel.user.storageId).toList();
  }
}
