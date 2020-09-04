import 'package:meta/meta.dart';
import 'package:sentry/sentry.dart' as sentryLib;

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/repositories/repositories.dart';

class Sentry {
  final UserRepository userRepo;
  final sentryLib.SentryClient client;
  final String osVersion;
  final String deviceModel;
  final bool capture;

  Sentry._({
    @required this.client,
    @required this.userRepo,
    @required this.osVersion,
    @required this.deviceModel,
    @required this.capture
  }) {
    _instance = this;
  }

  static Sentry _instance;
  static Sentry get instance => _instance;

  static Sentry init({
    @required String version,
    @required UserRepository userRepo,
    @required String dsn,
    @required bool capture,
    @required String osVersion,
    @required String deviceModel
  }) {
    if (_instance != null)
      return _instance;

    sentryLib.SentryClient client = sentryLib.SentryClient(
      dsn: dsn,
      environmentAttributes: sentryLib.Event(release: version)
    );

    return Sentry._(
      client: client,
      userRepo: userRepo,
      capture: capture,
      osVersion: osVersion,
      deviceModel: deviceModel
    );
  }

  Future<void> captureException(dynamic exception, dynamic stack) async {
    User user = userRepo.getUser();
    sentryLib.Event event = sentryLib.Event(
      exception: exception,
      stackTrace: stack,
      userContext: sentryLib.User(
        id: user.id.toString(),
        username: user.username,
        email: user.email
      ),
      environment: capture ? Strings.envProduction : Strings.envDevelopment,
      extra: {
        'osVersion': osVersion,
        'deviceModel': deviceModel
      }
    );

    if (capture) {
      await client.capture(event: event);
    }
  }
}
