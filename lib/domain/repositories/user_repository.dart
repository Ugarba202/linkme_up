import '../entities/user_entity.dart';
import '../entities/social_link_entity.dart';

abstract class IUserRepository {
  Future<void> createUser(UserEntity user);
  Future<UserEntity?> getUser(String uid);
  Future<void> updateUser(UserEntity user);
  Future<bool> isUsernameAvailable(String username);
  
  // Social Links Operations
  Future<void> addSocialLink(String uid, SocialLinkEntity link);
  Future<void> updateSocialLink(String uid, SocialLinkEntity link);
  Future<void> deleteSocialLink(String uid, String linkId);
}
