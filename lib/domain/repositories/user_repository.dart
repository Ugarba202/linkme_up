import '../entities/user_entity.dart';

abstract class IUserRepository {
  Future<void> createUser(UserEntity user);
  Future<UserEntity?> getUser(String uid);
  Future<void> updateUser(UserEntity user);
  Future<bool> isUsernameAvailable(String username);
}
