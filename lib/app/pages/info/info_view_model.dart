part of 'info_page.dart';

class InfoViewModel extends PageViewModel<InfoState, InfoStateStatus> {
  final AppRepository appRepository;
  final DeliveriesRepository deliveriesRepository;
  final UsersRepository usersRepository;
  Timer? fetchDataTimer;

  StreamSubscription<User>? userSubscription;
  StreamSubscription<AppInfoResult>? appInfoSubscription;
  StreamSubscription<List<ExDelivery>>? deliveriesSubscription;

  InfoViewModel(
    this.appRepository,
    this.deliveriesRepository,
    this.usersRepository
  ) : super(InfoState());

  @override
  InfoStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    userSubscription = usersRepository.watchUser().listen((event) {
      emit(state.copyWith(status: InfoStateStatus.dataLoaded, user: event));
    });
    appInfoSubscription = appRepository.watchAppInfo().listen((event) {
      emit(state.copyWith(status: InfoStateStatus.dataLoaded, appInfo: event));
    });
    deliveriesSubscription = deliveriesRepository.watchExDeliveries().listen((event) {
      emit(state.copyWith(status: InfoStateStatus.dataLoaded, deliveries: event));
    });

    await _checkNeedRefresh();

    fetchDataTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => emit(state.copyWith(status: InfoStateStatus.startLoad))
    );
  }

  @override
  Future<void> close() async {
    await super.close();

    await userSubscription?.cancel();
    await appInfoSubscription?.cancel();
    await deliveriesSubscription?.cancel();
    fetchDataTimer?.cancel();
  }

  Future<void> getData() async {
    await usersRepository.loadUserData();
    await appRepository.loadData();
  }

  Future<void> _checkNeedRefresh() async {
    final pref = await appRepository.watchAppInfo().first;

    if (pref.lastLoadTime == null) {
      emit(state.copyWith(status: InfoStateStatus.startLoad));
      return;
    }

    DateTime lastAttempt = pref.lastLoadTime!;
    DateTime time = DateTime.now();

    if (lastAttempt.year != time.year || lastAttempt.month != time.month || lastAttempt.day != time.day) {
      emit(state.copyWith(status: InfoStateStatus.startLoad));
    }
  }

  Future<void> closeDelivery() async {
    try {
      emit(state.copyWith(status: InfoStateStatus.closeInProgress));
      await deliveriesRepository.closeDelivery();
      await getData();

      emit(state.copyWith(status: InfoStateStatus.closeSuccess, message: 'День успешно завершен'));
    } on AppError catch(e) {
      emit(state.copyWith(status: InfoStateStatus.closeFailure, message: e.message));
    }
  }
}
