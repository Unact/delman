package ru.unact.delman

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    MapKitFactory.setApiKey(BuildConfig.DELMAN_YANDEX_API_KEY)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }
}
