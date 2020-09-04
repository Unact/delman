import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:delman/app/constants/strings.dart';

class Storage {
  final Database db;
  final SharedPreferences prefs;

  static const String schemaPath = 'lib/app/data/schema.sql';

  Storage._({@required this.prefs, @required this.db}) {
    _instance = this;
  }

  static Storage _instance;
  static Storage get instance => _instance;

  static Future<Storage> init() async {
    if (_instance != null)
      return _instance;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Database db = await _setupDataStores(prefs: prefs);

    return Storage._(prefs: prefs, db: db);
  }

  static Future<Database> _setupDataStores({SharedPreferences prefs}) async {
    String currentPath = (await getApplicationDocumentsDirectory()).path;
    String dbPath = '$currentPath/${Strings.appName}.db';
    List<String> schemaExps = (await rootBundle.loadString(schemaPath)).split(';');
    schemaExps.removeLast(); // Уберем перенос строки
    int prevVersion = schemaExps.join().hashCode;
    int version = prevVersion;
    Database db = await openDatabase(dbPath, version: version,
      onCreate: (Database db, int version) async {
        await Future.wait(schemaExps.map((exp) => db.execute(exp)));
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) => prevVersion = oldVersion,
      onDowngrade: (Database db, int oldVersion, int newVersion) => prevVersion = oldVersion
    );

    if (prevVersion != version) {
      await db.close();
      await prefs.clear();
      await deleteDatabase(dbPath);

      return await _setupDataStores(prefs: prefs);
    }

    return db;
  }
}
