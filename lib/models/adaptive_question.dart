enum QuestionType {
  multipleChoice,
  singleChoice,
  textInput,
  rating,
  yesNo,
  skillLevel,
}

enum SkillLevel { beginner, intermediate, advanced, expert }

class QuestionOption {
  final String id;
  final String text;
  final dynamic value;
  final String? nextQuestionId;
  final Map<String, dynamic>? metadata;

  const QuestionOption({
    required this.id,
    required this.text,
    required this.value,
    this.nextQuestionId,
    this.metadata,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'],
      text: json['text'],
      value: json['value'],
      nextQuestionId: json['next_question_id'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'value': value,
      'next_question_id': nextQuestionId,
      'metadata': metadata,
    };
  }
}

class AdaptiveQuestion {
  final String id;
  final String text;
  final String? subtitle;
  final QuestionType type;
  final List<QuestionOption> options;
  final bool isRequired;
  final String? validationPattern;
  final String? errorMessage;
  final Map<String, dynamic>? conditionalLogic;
  final List<String>? tags;
  final int? maxSelections;
  final int? minSelections;
  final double? minRating;
  final double? maxRating;

  const AdaptiveQuestion({
    required this.id,
    required this.text,
    this.subtitle,
    required this.type,
    this.options = const [],
    this.isRequired = true,
    this.validationPattern,
    this.errorMessage,
    this.conditionalLogic,
    this.tags,
    this.maxSelections,
    this.minSelections,
    this.minRating,
    this.maxRating,
  });

  factory AdaptiveQuestion.fromJson(Map<String, dynamic> json) {
    return AdaptiveQuestion(
      id: json['id'],
      text: json['text'],
      subtitle: json['subtitle'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => QuestionOption.fromJson(e))
              .toList() ??
          [],
      isRequired: json['is_required'] ?? true,
      validationPattern: json['validation_pattern'],
      errorMessage: json['error_message'],
      conditionalLogic: json['conditional_logic'],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      maxSelections: json['max_selections'],
      minSelections: json['min_selections'],
      minRating: json['min_rating']?.toDouble(),
      maxRating: json['max_rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'subtitle': subtitle,
      'type': type.toString().split('.').last,
      'options': options.map((e) => e.toJson()).toList(),
      'is_required': isRequired,
      'validation_pattern': validationPattern,
      'error_message': errorMessage,
      'conditional_logic': conditionalLogic,
      'tags': tags,
      'max_selections': maxSelections,
      'min_selections': minSelections,
      'min_rating': minRating,
      'max_rating': maxRating,
    };
  }
}

class QuestionResponse {
  final String questionId;
  final dynamic answer;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const QuestionResponse({
    required this.questionId,
    required this.answer,
    required this.timestamp,
    this.metadata,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      questionId: json['question_id'],
      answer: json['answer'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class AssessmentSession {
  final String id;
  final String userId;
  final List<QuestionResponse> responses;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String currentQuestionId;
  final Map<String, dynamic> context;
  final double progressPercentage;

  const AssessmentSession({
    required this.id,
    required this.userId,
    required this.responses,
    required this.startedAt,
    this.completedAt,
    required this.currentQuestionId,
    this.context = const {},
    this.progressPercentage = 0.0,
  });

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    return AssessmentSession(
      id: json['id'],
      userId: json['user_id'],
      responses: (json['responses'] as List<dynamic>)
          .map((e) => QuestionResponse.fromJson(e))
          .toList(),
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      currentQuestionId: json['current_question_id'],
      context: json['context'] ?? {},
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'responses': responses.map((e) => e.toJson()).toList(),
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'current_question_id': currentQuestionId,
      'context': context,
      'progress_percentage': progressPercentage,
    };
  }

  AssessmentSession copyWith({
    String? id,
    String? userId,
    List<QuestionResponse>? responses,
    DateTime? startedAt,
    DateTime? completedAt,
    String? currentQuestionId,
    Map<String, dynamic>? context,
    double? progressPercentage,
  }) {
    return AssessmentSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      responses: responses ?? this.responses,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentQuestionId: currentQuestionId ?? this.currentQuestionId,
      context: context ?? this.context,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  // Helper methods
  QuestionResponse? getResponseForQuestion(String questionId) {
    try {
      return responses.firstWhere((r) => r.questionId == questionId);
    } catch (e) {
      return null;
    }
  }

  bool hasAnsweredQuestion(String questionId) {
    return getResponseForQuestion(questionId) != null;
  }

  Map<String, dynamic> getAllAnswers() {
    final answers = <String, dynamic>{};
    for (final response in responses) {
      answers[response.questionId] = response.answer;
    }
    return answers;
  }
}
