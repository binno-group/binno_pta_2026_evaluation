enum AppFlavor { dev, staging, prod }

final class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.apiBaseUrl,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
}
