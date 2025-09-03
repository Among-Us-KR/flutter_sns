import 'package:flutter_sns/write/domain/entities/users.dart';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';

class GetUserProfileUseCase {
  final UserRepository _userRepository;

  GetUserProfileUseCase(this._userRepository);

  Future<User> execute(String uid) {
    return _userRepository.getUserProfile(uid);
  }
}
