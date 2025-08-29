// 데이터 전송 및 저장에 사용되는 모델 클래스 (DTO)

class WriteModel {
  final int id;
  final String name;

  WriteModel({required this.id, required this.name});

  factory WriteModel.fromJson(Map<String, dynamic> json) {
    return WriteModel(
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
