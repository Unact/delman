part of 'person_page.dart';

class PersonViewModel extends PageViewModel<PersonState, PersonStateStatus> {
  final AppRepository appRepository;
  final UsersRepository usersRepository;

  StreamSubscription<AppInfoResult>? appInfoSubscription;
  StreamSubscription<User>? userSubscription;

  PersonViewModel(this.appRepository, this.usersRepository) : super(PersonState());

  @override
  PersonStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    userSubscription = usersRepository.watchUser().listen((event) {
      emit(state.copyWith(status: PersonStateStatus.dataLoaded, user: event));
    });
    appInfoSubscription = appRepository.watchAppInfo().listen((event) {
      emit(state.copyWith(status: PersonStateStatus.dataLoaded, appInfo: event));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await userSubscription?.cancel();
    await appInfoSubscription?.cancel();
  }

  Future<void> apiLogout() async {
    emit(state.copyWith(status: PersonStateStatus.inProgress));

    try {
      await usersRepository.logout();
      await appRepository.clearData();
      emit(state.copyWith(status: PersonStateStatus.loggedOut));
    } on AppError catch(e) {
      emit(state.copyWith(status: PersonStateStatus.failure, message: e.message));
    }
  }

  Future<void> launchAppUpdate() async {
    Misc.launchAppUpdate(
      repoName: Strings.repoName,
      version: state.user!.version,
      onError: () => emit(state.copyWith(status: PersonStateStatus.failure, message: Strings.genericErrorMsg))
    );
  }

  Future<void> sendLogs() async {
    emit(state.copyWith(status: PersonStateStatus.inProgress));

    try {
      await appRepository.sendLogs();
      emit(state.copyWith(status: PersonStateStatus.logsSend, message: 'Информация успешно отправлена'));
    } on AppError catch(e) {
      emit(state.copyWith(status: PersonStateStatus.failure, message: e.message));
    }
  }
}
