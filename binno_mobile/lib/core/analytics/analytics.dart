abstract interface class Analytics {
  Future<void> track(String event, Map<String, Object?> properties);
}
