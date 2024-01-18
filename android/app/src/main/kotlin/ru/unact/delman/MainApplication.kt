package ru.unact.delman

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setLocale("ru_RU")
    MapKitFactory.setApiKey(BuildConfig.DELMAN_YANDEX_API_KEY)
  }
}
