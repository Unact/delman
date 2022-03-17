part of 'database.dart';

@DriftAccessor(tables: [ApiCredentials])
class ApiCredentialsDao extends DatabaseAccessor<AppStorage> with _$ApiCredentialsDaoMixin {
  ApiCredentialsDao(AppStorage db) : super(db);

  Future<ApiCredential> getApiCredential() async {
    return await (select(apiCredentials).getSingleOrNull()) ?? ApiCredential(
      id: AppStorage.kSingleRecordId,
      refreshToken: '',
      url: '',
      accessToken: ''
    );
  }

  Future<int> updateApiCredential(ApiCredential apiCredential) {
    return into(apiCredentials).insertOnConflictUpdate(apiCredential);
  }

  Future<int> deleteApiCredential() {
    return delete(apiCredentials).go();
  }
}
