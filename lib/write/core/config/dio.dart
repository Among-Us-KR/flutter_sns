// Dio HTTP 클라이언트 설정 및 공통 인터셉터 등 구성
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: 5000,
  receiveTimeout: 3000,
));
