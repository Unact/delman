part of 'order_storages_page.dart';

class OrderStoragesViewModel extends PageViewModel<OrderStoragesState, OrderStoragesStateStatus> {
  OrderStoragesViewModel(BuildContext context) : super(context, OrderStoragesState());

  @override
  OrderStoragesStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.users,
    app.storage.orderStorages
  ]);

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: OrderStoragesStateStatus.dataLoaded,
      orderStorages: await app.storage.orderStoragesDao.getForeignOrderStorages()
    ));
  }
}
