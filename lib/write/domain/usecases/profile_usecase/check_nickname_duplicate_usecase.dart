import 'package:flutter_sns/write/core/services/nickname_validator.dart';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';

class CheckNicknameDuplicateUseCase {
  final UserRepository _repo;
  CheckNicknameDuplicateUseCase(this._repo);

  /// 이미 존재하면 true
  Future<bool> execute(String nickname) async {
    final lower = NicknamePolicy.normalizedLower(nickname);
    return _repo.isNicknameDuplicate(lower);
  }
}
