import 'package:intelligent_career_counselling/services/adaptive_assessment_service.dart';

void main() {
  print('🧪 Testing Enhanced Assessment Questions\n');

  final service = AdaptiveAssessmentService.instance;

  // Test if new questions exist
  final newQuestions = [
    'personality_type',
    'work_style_preference',
    'learning_preference',
    'motivation_factors',
    'tech_specialization',
    'business_role_type',
    'creative_domain',
    'healthcare_path',
    'career_challenges',
    'ideal_company_size',
  ];

  print('📋 Checking new questions exist:');
  for (final questionId in newQuestions) {
    final question = service.getQuestionById(questionId);
    if (question != null) {
      print('✅ $questionId: "${question.text}"');
      print('   Options: ${question.options.length}');
    } else {
      print('❌ Missing: $questionId');
    }
  }

  print('\n🎯 Enhanced assessment system loaded successfully!');
  print('Questions tested: ${newQuestions.length}');
}
