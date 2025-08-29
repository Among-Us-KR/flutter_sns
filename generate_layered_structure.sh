#!/bin/bash

# generate_layered_structure.sh
# 파일 생성 후 1번은 권한을 부여해 줘야함
# - chmod +x generate_layered_structure.sh
# 실행 방법
# ./generate_layered_structure.sh <feature_name>
# Usage 안내 및 입력 체크

if [ -z "$1" ]; then
  echo "Usage: ./generate_layered_structure.sh <feature_name>"
  exit 1
fi

FEATURE=$1
FEATURE_CAP="$(tr '[:lower:]' '[:upper:]' <<< ${FEATURE:0:1})${FEATURE:1}"

echo "Generating layered structure for feature '$FEATURE'..."

BASE=lib/$FEATURE

# 1. 폴더 생성
mkdir -p $BASE/core/config
mkdir -p $BASE/core/error
mkdir -p $BASE/core/network
mkdir -p $BASE/data/datasources
mkdir -p $BASE/data/models
mkdir -p $BASE/data/repositories
mkdir -p $BASE/domain/entities
mkdir -p $BASE/domain/repositories
mkdir -p $BASE/domain/usecases
mkdir -p $BASE/presentation/screens
mkdir -p $BASE/presentation/providers
mkdir -p $BASE/presentation/widgets

# 2. 파일 생성 및 기본 템플릿 삽입

# core/config/dio.dart
cat > $BASE/core/config/dio.dart << EOF
// Dio HTTP 클라이언트 설정 및 공통 인터셉터 등 구성
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: 5000,
  receiveTimeout: 3000,
));
EOF

# core/error/exceptions.dart
cat > $BASE/core/error/exceptions.dart << EOF
// 앱에서 발생하는 예외 정의 및 처리용 커스텀 예외 클래스

class ${FEATURE_CAP}Exception implements Exception {
  final String message;
  ${FEATURE_CAP}Exception(this.message);

  @override
  String toString() => '${FEATURE_CAP}Exception: \$message';
}
EOF

# data/datasources/${feature}_datasource.dart
cat > $BASE/data/datasources/${FEATURE}_datasource.dart << EOF
// ${FEATURE_CAP} 관련 API 호출 구현 (예: Firebase, REST API 등)

abstract class ${FEATURE_CAP}DataSource {
  Future<String> fetchData();
}

class ${FEATURE_CAP}DataSourceImpl implements ${FEATURE_CAP}DataSource {
  @override
  Future<String> fetchData() async {
    // TODO: 실제 API 호출 구현
    return 'data from ${FEATURE_CAP}DataSource';
  }
}
EOF

# data/models/${feature}_model.dart
cat > $BASE/data/models/${FEATURE}_model.dart << EOF
// 데이터 전송 및 저장에 사용되는 모델 클래스 (DTO)

class ${FEATURE_CAP}Model {
  final int id;
  final String name;

  ${FEATURE_CAP}Model({required this.id, required this.name});

  factory ${FEATURE_CAP}Model.fromJson(Map<String, dynamic> json) {
    return ${FEATURE_CAP}Model(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
EOF

# data/repositories/${feature}_repository_impl.dart
cat > $BASE/data/repositories/${FEATURE}_repository_impl.dart << EOF
import '../../domain/entities/${FEATURE}.dart';
import '../../domain/repositories/${FEATURE}_repository.dart';
import '../datasources/${FEATURE}_datasource.dart';

// 도메인 레이어에서 정의한 인터페이스 구현체 (데이터 조작)

class ${FEATURE_CAP}RepositoryImpl implements ${FEATURE_CAP}Repository {
  final ${FEATURE_CAP}DataSource dataSource;

  ${FEATURE_CAP}RepositoryImpl(this.dataSource);

  @override
  Future<${FEATURE_CAP}> get${FEATURE_CAP}() async {
    // TODO: 데이터 변환, 캐싱 등 로직 추가
    final rawData = await dataSource.fetchData();
    // 예시: rawData를 ${FEATURE_CAP} 객체로 매핑 필요
    return ${FEATURE_CAP}(id: 1, name: rawData);
  }
}
EOF

# domain/entities/${feature}.dart
cat > $BASE/domain/entities/${FEATURE}.dart << EOF
// 비즈니스 규칙이 담긴 핵심 엔티티 클래스

class ${FEATURE_CAP} {
  final int id;
  final String name;

  ${FEATURE_CAP}({required this.id, required this.name});
}
EOF

# domain/repositories/${feature}_repository.dart
cat > $BASE/domain/repositories/${FEATURE}_repository.dart << EOF
import '../entities/${FEATURE}.dart';

// 추상화된 저장소 인터페이스 정의

abstract class ${FEATURE_CAP}Repository {
  Future<${FEATURE_CAP}> get${FEATURE_CAP}();
}
EOF

# domain/usecases/get_${feature}_usecase.dart
cat > $BASE/domain/usecases/get_${FEATURE}_usecase.dart << EOF
import '../entities/${FEATURE}.dart';
import '../repositories/${FEATURE}_repository.dart';

// 앱의 주요 동작(유즈케이스) 구현 (비즈니스 로직)

class Get${FEATURE_CAP}UseCase {
  final ${FEATURE_CAP}Repository repository;

  Get${FEATURE_CAP}UseCase(this.repository);

  Future<${FEATURE_CAP}> execute() {
    return repository.get${FEATURE_CAP}();
  }
}
EOF

# presentation/screens/${feature}_screen.dart
cat > $BASE/presentation/screens/${FEATURE}_screen.dart << EOF
import 'package:flutter/material.dart';

// 화면 단위 UI 위젯

class ${FEATURE_CAP}Screen extends StatelessWidget {
  const ${FEATURE_CAP}Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${FEATURE_CAP} Screen')),
      body: Center(child: Text('This is the ${FEATURE_CAP} screen')),
    );
  }
}
EOF

# presentation/providers/${feature}_provider.dart
cat > $BASE/presentation/providers/${FEATURE}_provider.dart << EOF
// 상태관리 (예: Riverpod, Provider 등) 예시

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_${FEATURE}_usecase.dart';

final ${FEATURE}_provider = FutureProvider.autoDispose((ref) async {
  final usecase = ref.read(get${FEATURE_CAP}UseCaseProvider);
  return await usecase.execute();
});
EOF

# presentation/widgets/${feature}_widget.dart
cat > $BASE/presentation/widgets/${FEATURE}_widget.dart << EOF
import 'package:flutter/material.dart';

// 재사용 가능한 위젯 컴포넌트 예시

class ${FEATURE_CAP}Widget extends StatelessWidget {
  final String text;

  const ${FEATURE_CAP}Widget({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}
EOF

echo "Layered structure with example code for feature '$FEATURE' created successfully!"
