import 'package:flutter_sns/write/domain/entities/users.dart';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';

class UpdateUserProfileUseCase {
  final UserRepository _userRepository;

  UpdateUserProfileUseCase(this._userRepository);

  Future<void> execute(User user) {
    return _userRepository.updateUserProfile(user);
  }
}
