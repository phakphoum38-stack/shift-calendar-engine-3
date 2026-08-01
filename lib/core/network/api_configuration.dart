class ApiConfiguration {
  const ApiConfiguration({required this.baseUrl});

  factory ApiConfiguration.fromEnvironment() {
    const configuredUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000',
    );

    return const ApiConfiguration(baseUrl: configuredUrl);
  }

  final String baseUrl;

  Uri resolve(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final normalizedPath = path.startsWith('/') ? path : '/$path';

    final uri = Uri.parse('$normalizedBaseUrl$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final parameters = <String, String>{};

    for (final entry in queryParameters.entries) {
      final value = entry.value;

      if (value == null) {
        continue;
      }

      final text = value.toString();

      if (text.isNotEmpty) {
        parameters[entry.key] = text;
      }
    }

    return uri.replace(queryParameters: parameters);
  }
}
