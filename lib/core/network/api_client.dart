/// Interface or wrapper for HTTP / API client operations
abstract class ApiClient {
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters});
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body});
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body});
  Future<dynamic> delete(String endpoint);
}
