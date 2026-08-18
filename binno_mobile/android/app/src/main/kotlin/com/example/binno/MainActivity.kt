package com.example.binno

import android.app.Application
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()

/// The MapKit API key must be set at app startup, before any map is
/// created, which is why it lives at the Application level.
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey(BinnoConfig.YANDEX_MAPKIT_KEY)
    }
}

object BinnoConfig {
    const val YANDEX_MAPKIT_KEY = "YOUR_YANDEX_MAPKIT_KEY"
}
