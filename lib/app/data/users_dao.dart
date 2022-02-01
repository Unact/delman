part of 'database.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppStorage> with _$UsersDaoMixin {
  static const int kGuestId = 1;
  static const String kGuestUsername = 'guest';

  UsersDao(AppStorage db) : super(db);

  Future<User> getUser() async {
    return await (select(users).getSingle());
  }

  Future<int> loadUser(User user) async {
    return transaction(() async {
      await delete(users).go();
      return await into(users).insert(user);
    });
  }
}
