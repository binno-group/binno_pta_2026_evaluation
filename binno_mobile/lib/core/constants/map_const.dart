/// Yandex MapKit settings.
///
/// The API key is also set on the **native side** (Android:
/// `MainActivity.kt`, iOS: `AppDelegate.swift`); MapKit reads it from the
/// platform, not from Dart. The copy here is for documentation and checks.
abstract class MapConst {
  static const apiKey = 'YOUR_YANDEX_MAPKIT_KEY';

  /// The centre of Tashkent, the initial camera point while no address is
  /// picked yet.
  static const defaultLat = 41.311081;
  static const defaultLng = 69.240562;

  /// The zoom used while picking an address (house numbers visible).
  static const pickerZoom = 17.0;

  /// The zoom for showing a store or complex location.
  static const previewZoom = 15.5;
}
