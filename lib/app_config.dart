enum Environment { staging, prod }

class AppConfig {
  static late Environment env;
  static late String apiBaseUrl;
  static late bool enableLogs;

  static void init({
    required Environment env,
    required String apiBaseUrl,
    required bool enableLogs,
  }) {
    AppConfig.env = env;
    AppConfig.apiBaseUrl = apiBaseUrl;
    AppConfig.enableLogs = enableLogs;
  }

  static bool get isProd => env == Environment.prod;
}
