# flutter_sns  
A new Flutter project.

## 개발 환경

- Flutter 3.35.2  
- Dart 3.9.0  
- 피그마 경로: [https://www.figma.com/design/dX7VbtoBQi5DBEAy0uLspO/Flutter-%EC%8B%AC%ED%99%94-4%EC%A1%B0?node-id=0-1&p=f&t=USO6iZHoWwi8QqTQ-0](https://www.figma.com/design/dX7VbtoBQi5DBEAy0uLspO/Flutter-%EC%8B%AC%ED%99%94-4%EC%A1%B0?node-id=0-1&p=f&t=USO6iZHoWwi8QqTQ-0)

## 구조

```plaintext
assets/
├── config/
│   └── .env/
├── fonts/       // 앱 전반에서 공통으로 사용되는 font
├── icons/       // 앱 전반에서 공통으로 사용되는 아이콘
├── images/
└── logo/        // 앱의 로고 이미지 
lib/
├── core/        // 앱 전반에서 공통으로 쓰이는 설정 및 예외 처리 모음
│   ├── config/
│   │   └── dio.dart           // Dio HTTP 클라이언트 설정 및 공통 인터셉터 등 구성
│   └── error/
│       └── exceptions.dart    // 앱에서 발생하는 예외 정의 및 처리용 커스텀 예외 클래스
├── data/        // 데이터 계층 - 외부 데이터 소스와 통신하고 모델 관리
│   ├── datasources/
│   │   └── firebase_storage_datasource.dart  // Firebase Storage 관련 API 호출 구현
│   ├── models/
│   │   └── upload_model.dart                   // 데이터 전송 및 저장에 사용되는 모델 클래스 (DTO)
│   └── repositories/
│       └── upload_repository_impl.dart        // 도메인 레이어에서 정의한 인터페이스 구현체 (데이터 조작)
├── domain/      // 도메인 계층 - 비즈니스 로직 및 핵심 엔티티 관리
│   ├── entities/
│   │   └── upload_entity.dart                  // 비즈니스 규칙이 담긴 핵심 엔티티 클래스
│   ├── repositories/
│   │   └── upload_repository.dart              // 추상화된 저장소 인터페이스 정의
│   └── usecases/
│       └── upload_image_usecase.dart           // 앱의 주요 동작(유즈케이스) 구현 (비즈니스 로직)
├── presentation/ // UI 계층 - 화면, 상태관리, 위젯 등
│   ├── screens/
│   │   ├── home
│   │   ├── post_detail
│   │   ├── profile
│   │   ├── write
│   │   └── upload_screen.dart                   // 이미지 업로드 화면 위젯 (페이지 단위)
│   ├── providers/
│   │   └── upload_provider.dart                 // 상태 관리 및 비즈니스 로직과 UI 연결 (예: Provider)
│   └── widgets/
│       ├── splash_screen.dart                   //스플래시 설정
│       └── upload_button.dart                   // 재사용 가능한 UI 컴포넌트 (버튼 등)
├── firebase_options.dart                        // firebase 기본 
├── app.dart                                     // 라우팅 설정 테마설정
└── main.dart                                     // 앱 진입점, Firebase 초기화 


 ## 전체 실행흐름 
 
 ```
 main.dart 
 → MyApp (in app.dart) 
 → GoRouter 시작 
 → SplashScreen 
 → context.go('/') 
 → HomePage 
 ``` 

## 필수구현 사항

  

### 화면 구성

- [ ] 디자인된 와이어프레임을 보고, 코드로 레이아웃을 나눌 수 있습니다.
- [ ] 다양한 위젯과 속성을 활용해 UI 를 구성합니다.
- [ ] Splash 화면에서 애니메이션을 구현할 수 있습니다.

### 기능 구현

- [ ] `Firebase Firestore`와 연동하여 데이터를 주고받을 수 있습니다.
- [ ] `ImagePicker` 패키지와 `Firebase Storage`를 이용하여 사진 업로드 기능을 구현할 수 있습니다.
- [ ] PageView 에서 `무한스크롤` 기능을 구현할 수 있습니다.
- [ ] `TF Lite` 패키지와 `YOLO` 모델을 이용하여 사람이 들어간 사진의 업로드를 제한할 수 있습니다.
- [ ] `Firebase Analytics`, `Crashlytics` 를 연동할 수 있습니다.

### 설계

- [ ] 클린 아키텍처로 프로젝트를 설계할 수 있습니다
- [ ] 각 단계 별 Mock 클래스를 사용하여 테스트 코드를 작성할 수 있습니다.

  

## 가이드 내용 확인 

**Home** feeds 무한 스크롤 기능 구현
- PageView를 이용해 `사진` `내용` `태그` `업로드날짜` `댓글아이콘` 전체화면 출력
- 글작성 버튼은 화면 하단 가운데 배치
Firebase Firestore 에서 데이터 가져올 때 특정 갯수만큼 끊어서 가지고 올 수 있게 구현합니다 (영화앱 참고 )

**Write** Firebase Firestore - feeds
feed 생성 시 이미지 업로드 할 수 있게 Firebase Stroage 연동 및 image_picker 패키지 적용
- `태그명` 입력란, `내용` 입력란, `이미지` 업로드 영역 출력
WritePage 를 재사용하여 글 수정 기능을 구현합니다
글 수정 시 사용자가 별도의 저장 버튼을 누르지 않아도, 마지막 입력 후 일정 시간이 지나면 자동으로 저장되는 디바운싱 기능을 구현합니다.
  
**Comment** Firebase Firestore - comments
comments 컬렉션 가지고 올 때 특정 feed에 해당하는 댓글만 가지고 올 수 있도록 구현
- `댓글내용` `댓글작성일` 출력
- 화면 하단에 댓글 입력창 및 아이콘 출력
- 앱바에 댓글 갯수 출력

**Splash**
- 화면 애니메이션 구현 후 애니메이션 종료 후 화면 전환
  
```
* 페이지 이동처리는 context.go
* 텐서플로우 라이트와 YOLO 모델을 이용하여 이미지 업로드 시 사람이 포함된 사진은 업로드 할 수 없도록 구현합니다
* 배포 이후에 사용자의 디바이스에서 에러 발생 시 추적이 용이하도록 Firebase Crashlytics를 연동합니다
* 추후 UX를 개선할 수 있게 Firebase Analytics를 연동하여 앱내의 버튼, 텍스트 입력, 페이지에 머문 시간 등을 기록합니다
* 앱이 실행 중일 때, 내가 작성한 글에 댓글이 달리면 로컬 알림이 표시됩니다
* 내가 작성한 글에 댓글이 달리는지는 Firestore 의 where 필터기능과 실시간 스트림을 이용해서 구현할 수 있습니다
```
  
  

## 설치된 패키지 (flutter pub deps 로 조회)

### 🧪 운영(Prd) 전용 패키지 & 도구
| 목적                    | 패키지명                         | 설치 명령어                                                | 비고/개선 영역                        |
| --------------------- | ---------------------------- | ----------------------------------------------------- | ------------------------------- |
| `.env` 파일 읽기          | `flutter_dotenv`             | `flutter pub add flutter_dotenv`                      | 환경변수 관리                         |
| Firebase 필수 초기화       | `firebase_core`              | `flutter pub add firebase_core`                       | Firebase 기본                     |
| Firebase 사용자 인증       | `firebase_auth`              | `flutter pub add firebase_auth`                       | 사용자 로그인, 회원가입, 인증 상태 관리         |
| Firebase 이미지 저장       | `firebase_storage`           | `flutter pub add firebase_storage`                    | 사진, 파일 저장                       |
| Firebase 데이터베이스       | `cloud_firestore`            | `flutter pub add cloud_firestore`                     | 실시간 DB                          |
| Firebase 앱 분석         | `firebase_analytics`         | `flutter pub add firebase_analytics`                  | 사용자 행동 분석 (UX 개선)               |
| Firebase 예외 및 크래시 리포트 | `firebase_crashlytics`       | `flutter pub add firebase_crashlytics`                | 에러 추적 (실시간 모니터링)                |
| Firebase 푸시 알림        | `firebase_messaging`         | `flutter pub add firebase_messaging`                  | 푸시 알림                           |
| 이미지 선택 (카메라/갤러리)      | `image_picker`               | `flutter pub add image_picker`                        | 갤러리/카메라 이미지 선택                  |
| 라우팅 (context.go)      | `go_router`                  | `flutter pub add go_router`                           | 페이지 이동 처리 (라우팅)                 |
| TensorFlow Lite 실행    | `tflite_flutter`             | `flutter pub add tflite_flutter`                      | AI 모델 실행 (YOLO 포함)              |
| 앱 네트워크 상태 감지          | `connectivity_plus`          | `flutter pub add connectivity_plus`                   | 인터넷 연결 여부 확인                    |
| 이미지 캐싱 및 최적화          | `cached_network_image`       | `flutter pub add cached_network_image`                | 이미지 캐싱 및 최적화                    |
| 앱 내 폰트/글꼴 관리          | `google_fonts`               | `flutter pub add google_fonts`                        | 구글 폰트 사용                        |
| 앱 권한 요청 관리            | `permission_handler`         | `flutter pub add permission_handler`                  | 권한 요청 관리 (카메라, 저장소 등)           |
| 로깅 및 디버깅              | `logger`                     | `flutter pub add logger`                              | 개발 단계 로그 관리 및 디버깅 지원            |
| 이미지 크기 조정             | `flutter_image_compress`     | `flutter pub add flutter_image_compress`              | 이미지 압축 및 리사이징                   |
| 클린 아키텍처 코드 생성 (CLI)   | `clean_arch_boilerplate_cli` | `dart pub global activate clean_arch_boilerplate_cli` | 클린 아키텍처 기반 프로젝트 자동 생성 (생산성 향상)  |
| 클린 아키텍처 구현 구조 지원      | `flutter_clean_architecture` | `flutter pub add flutter_clean_architecture`          | 클린 아키텍처 지원 (유지보수 및 확장성 향상)      |
| 상태관리 (Provider 방식)    | `provider`                   | `flutter pub add provider`                            | 상태관리 (단순하고 직관적)                 |
| 상태관리 (Riverpod 방식)    | `flutter_riverpod`           | `flutter pub add flutter_riverpod`                    | 상태관리 (강력하고 안전한 구조)              |
| 객체 비교 편의성             | `equatable`                  | `flutter pub add equatable`                           | 객체 비교 간소화                       |
| HTTP 통신               | `dio`                        | `flutter pub add dio`                                 | 네트워크 통신 (인터셉터, 로깅 등 고급 기능 지원)   |
| JSON 직렬화/역직렬화 어노테이션   | `json_annotation`            | `flutter pub add json_annotation`                     | JSON 코드 자동 생성 위한 어노테이션          |
| 날짜/시간 관리              | `intl`                       | `flutter pub add intl`                                | 날짜, 시간 포맷 및 국제화 지원              |
| 다국어 지원                | `flutter_localizations`      | Flutter SDK 기본 포함                                     | 앱 내 다국어 지원 (pubspec.yaml 설정 필요) |

---

### 🧪 개발(Dev) 전용 패키지 

| 목적                    | 패키지명                         | 설치 명령어                                                | 비고/개선 영역                        |
| --------------------- | ---------------------------- | ----------------------------------------------------- | ------------------------------- |
|코드 생성 도구 (빌드러너)|`build_runner`|`flutter pub add --dev build_runner`|코드 자동 생성, 생산성 향상|
|JSON 코드 생성 라이브러리|`json_serializable`|`flutter pub add --dev json_serializable`|JSON 직렬화 코드 자동 생성|
|테스트 프레임워크 (기본 포함)|`flutter_test`|✅ 기본 포함|유닛 테스트 및 위젯 테스트 자동화 (버그 조기 발견)|
|테스트용 Mock 생성|`mockito`|`flutter pub add --dev mockito`|Mock 객체 생성, 테스트 용이성 향상|
| UI 통합 테스트 | `integration_test` | 기본 포함 (Flutter SDK) | 실제 디바이스 환경 UI 테스트 |

  

---
## 튜터님 추천

🔥 Flutter에서 이미지 용량 줄이는 방법
1. 이미지 압축 패키지 image
    Dart 순수 라이브러리로 이미지 리사이즈, 포맷 변환 등이 가능하지만 속도는 느린 편입니다.
    (사용예정) flutter_image_compress - 이미지 크기, 품질을 조절해서 압축할 수 있는 대표 패키지입니다.
2.이메일 인증과 flutter_secure_storage 활용 시 고려사항
1. flutter_secure_storage 역할
    OS의 **안전한 저장소(Keychain, Keystore)**를 이용해 민감한 데이터를 암호화해서 저장합니다.
    주로 액세스 토큰, 리프레시 토큰, 비밀번호, 인증 토큰 등을 저장하는 데 적합합니다.
    앱 삭제 시 데이터도 같이 삭제됩니다 (앱 전용 저장소라서).
2. 이메일 인증 로그인 방식
    보통 이메일 + 비밀번호 조합 또는 이메일 링크 인증 방식을 사용.
    이메일 인증 완료 후, 서버에서 **인증 토큰(access token, refresh token)**을 발급받아 저장합니다.
    이 토큰을 flutter_secure_storage에 저장하면 안전하게 보관할 수 있습니다.
3. 문제가 될 수 있는 상황?
    이메일 인증 자체는 별도의 세션이나 토큰 없이도 작동 가능하지만,
    앱 내에서 인증 상태를 유지하려면 토큰 저장이 필요합니다.
    flutter_secure_storage는 이 부분에서 안전한 저장소 역할을 잘 해줍니다.
    앱 삭제 시 저장된 토큰은 삭제되므로, 재로그인이 필요하지만 이는 보안상 바람직합니다.
4. 추가로 고려할 점
    만약 이메일 인증 링크를 통한 로그인이라면, 인증 완료 후 토큰을 받아 안전히 저장하는 흐름을 구현해야 합니다.
    **자동 로그인(토큰 기반)**을 지원하려면 flutter_secure_storage에 토큰 저장이 필수적입니다.
    토큰 갱신(refresh token) 기능도 같이 구현해야 사용자 경험이 좋아집니다.
3. Firebase Authentication 이메일 인증 예시
    Firebase Authentication 이메일/비밀번호 인증은 무료로 제공되는 범위가 큽니다.
    <<Firebase Authentication 요금 정책 요약>>
    1. Spark 요금제 (무료 플랜)
    이메일/비밀번호, 소셜 로그인 등 대부분의 인증 방식은 무제한 무료입니다.