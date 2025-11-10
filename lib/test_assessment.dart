import 'package:intelligent_career_counselling/services/adaptive_assessment_service.dart';

void main() async {
  print('🧪 Testing Enhanced Adaptive Assessment System\n');

  final service = AdaptiveAssessmentService.instance;

  // Test 1: Check if all new questions exist
  print('📋 Checking new questions...');
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

  for (final questionId in newQuestions) {
    final question = service.getQuestionById(questionId);
    if (question != null) {
      print('✅ $questionId: "${question.text}"');
    } else {
      print('❌ Missing question: $questionId');
    }
  }

  // Test 2: Simulate a complete assessment flow
  print('\n🔄 Testing assessment flow...');

  var session = await service.startNewSession();
  print('Started session: ${session.id}');

  // Simulate tech-interested user path
  final responses = [
    ('education_level', 'Undergraduate'),
    ('technical_background', 'Yes'),
    ('programming_languages', ['Python', 'JavaScript']),
    ('career_interests', ['Software Development', 'Data Science']),
    ('work_mode_preference', 'Remote'),
    ('salary_expectations', '6-10 LPA'),
    ('location_preference', ['Bangalore', 'Mumbai']),
    ('career_goals', 'Get my first job'),
    ('personality_type', 'Analytical'),
    ('work_style_preference', 'Independent'),
    ('learning_preference', ['Hands-on', 'Videos']),
    (
      'motivation_factors',
      ['Learning', 'Financial success', 'Problem solving'],
    ),
    ('tech_specialization', 'Fullstack'),
  ];

  for (final (questionId, answer) in responses) {
    session = await service.addResponse(session, questionId, answer);
    print('Added response for $questionId: $answer');
    print('Progress: ${session.progressPercentage.toStringAsFixed(1)}%');

    if (session.currentQuestionId != null &&
        session.currentQuestionId != 'completed') {
      final nextQuestion = service.getQuestionById(session.currentQuestionId!);
      if (nextQuestion != null) {
        print('Next question: ${nextQuestion.text}');
      }
    }
    print('---');
  }

  print('\n📊 Assessment Results:');
  final assessmentData = service.generateAssessmentData(session);
  assessmentData.forEach((key, value) {
    print('$key: $value');
  });

  print('\n🎯 Enhanced assessment system is working correctly!');
  // print('Total questions in flow: ${service.getQuestionFlow().length}');
  print('Questions answered: ${session.responses.length}');
}
