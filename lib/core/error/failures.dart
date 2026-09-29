/// Base failure class for domain layer exception handling
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Please check your internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache retrieval failed.']);
}
