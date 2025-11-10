class CareerGuidance {
  final String id;
  final String userId;
  final String prompt;
  final String response;
  final Map<String, dynamic> assessmentData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CareerGuidance({
    required this.id,
    required this.userId,
    required this.prompt,
    required this.response,
    required this.assessmentData,
    required this.createdAt,
    this.updatedAt,
  });

  factory CareerGuidance.fromJson(Map<String, dynamic> json) {
    return CareerGuidance(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      prompt: json['prompt'] ?? '',
      response: json['response'] ?? '',
      assessmentData: Map<String, dynamic>.from(json['assessment_data'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'prompt': prompt,
      'response': response,
      'assessment_data': assessmentData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'user_id': userId,
      'prompt': prompt,
      'response': response,
      'assessment_data': assessmentData,
    };
  }

  CareerGuidance copyWith({
    String? id,
    String? userId,
    String? prompt,
    String? response,
    Map<String, dynamic>? assessmentData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CareerGuidance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      prompt: prompt ?? this.prompt,
      response: response ?? this.response,
      assessmentData: assessmentData ?? this.assessmentData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
