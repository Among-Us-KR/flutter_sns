import 'package:flutter_sns/write/domain/entities/users.dart';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';

class UpdateUserStatsUseCase {
  final UserRepository _userRepository;

  UpdateUserStatsUseCase(this._userRepository);

  Future<void> execute(String uid, UserStats stats) {
    return _userRepository.updateUserStats(uid, stats);
  }
}
