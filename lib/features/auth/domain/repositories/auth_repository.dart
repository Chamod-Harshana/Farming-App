import '../entities/user_entity.dart';

/// Repository interface for authentication domain contract
abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
}
