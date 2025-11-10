import '../models/adaptive_question.dart';
import '../services/auth_service.dart';

class AdaptiveAssessmentService {
  static final AdaptiveAssessmentService _instance =
      AdaptiveAssessmentService._internal();
  factory AdaptiveAssessmentService() => _instance;
  AdaptiveAssessmentService._internal();

  static AdaptiveAssessmentService get instance => _instance;

  // Question flow logic
  String? getNextQuestionId(
    String currentQuestionId,
    dynamic answer,
    Map<String, dynamic> context,
  ) {
    final question = getQuestionById(currentQuestionId);
    if (question == null) return null;

    // Check if the selected option has a specific next question
    if (question.type == QuestionType.singleChoice ||
        question.type == QuestionType.yesNo) {
      final selectedOption = question.options.firstWhere(
        (option) => option.value == answer,
        orElse: () => question.options.first,
      );
      if (selectedOption.nextQuestionId != null) {
        return selectedOption.nextQuestionId;
      }
    }

    // Apply conditional logic based on context and answers
    final nextId = _applyConditionalLogic(currentQuestionId, answer, context);

    // Debug print to track the flow
    print('🔄 Question Flow: $currentQuestionId (answer: $answer) → $nextId');

    return nextId;
  }

  String? _applyConditionalLogic(
    String currentQuestionId,
    dynamic answer,
    Map<String, dynamic> context,
  ) {
    switch (currentQuestionId) {
      case 'education_level':
        if (answer == 'Class 10' || answer == 'Class 12') {
          return 'stream_selection';
        } else if (answer == 'Working Professional') {
          return 'work_experience';
        } else {
          return 'technical_background';
        }

      case 'stream_selection':
        context['stream'] = answer;
        return 'technical_background';

      case 'work_experience':
        return 'technical_background';

      case 'technical_background':
        if (answer == 'Yes') {
          return 'programming_languages';
        } else {
          return 'career_interests';
        }

      case 'programming_languages':
        return 'career_interests';

      case 'career_interests':
        return 'work_mode_preference';

      case 'work_mode_preference':
        return 'salary_expectations';

      case 'salary_expectations':
        return 'location_preference';

      case 'location_preference':
        return 'career_goals';

      case 'career_goals':
        return 'personality_type';

      case 'personality_type':
        return 'work_style_preference';

      case 'work_style_preference':
        return 'learning_preference';

      case 'learning_preference':
        return 'motivation_factors';

      case 'motivation_factors':
        return _getIndustrySpecificQuestion(context);

      case 'tech_specialization':
      case 'business_role_type':
      case 'creative_domain':
      case 'healthcare_path':
        return 'skill_assessment';

      case 'skill_assessment':
        return 'career_challenges';

      case 'career_challenges':
        return 'ideal_company_size';

      case 'ideal_company_size':
        return null; // End of assessment

      default:
        return _getDefaultNextQuestion(currentQuestionId);
    }
  }

  String? _getIndustrySpecificQuestion(Map<String, dynamic> context) {
    final interests = context['career_interests'];
    if (interests == null) return 'skill_assessment';

    if (interests is List) {
      // Check for tech interests
      if (interests.any(
        (interest) =>
            ['Software Development', 'Data Science'].contains(interest),
      )) {
        return 'tech_specialization';
      }
      // Check for business interests
      if (interests.any(
        (interest) =>
            ['Finance', 'Marketing', 'Entrepreneurship'].contains(interest),
      )) {
        return 'business_role_type';
      }
      // Check for creative interests
      if (interests.any((interest) => ['Design'].contains(interest))) {
        return 'creative_domain';
      }
      // Check for healthcare interests
      if (interests.any((interest) => ['Healthcare'].contains(interest))) {
        return 'healthcare_path';
      }
    }

    return 'skill_assessment'; // Default path
  }

  String? _getDefaultNextQuestion(String currentQuestionId) {
    final questionFlow = _getQuestionFlow();
    final currentIndex = questionFlow.indexOf(currentQuestionId);
    if (currentIndex != -1 && currentIndex < questionFlow.length - 1) {
      return questionFlow[currentIndex + 1];
    }
    return null;
  }

  List<String> _getQuestionFlow() {
    return [
      'education_level',
      'stream_selection',
      'work_experience',
      'technical_background',
      'programming_languages',
      'career_interests',
      'work_mode_preference',
      'salary_expectations',
      'location_preference',
      'career_goals',
      'personality_type',
      'work_style_preference',
      'learning_preference',
      'motivation_factors',
      'tech_specialization',
      'business_role_type',
      'creative_domain',
      'healthcare_path',
      'skill_assessment',
      'career_challenges',
      'ideal_company_size',
    ];
  }

  // Session management
  Future<AssessmentSession> startNewSession() async {
    final userId = AuthService.instance.userId ?? 'anonymous';
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    final session = AssessmentSession(
      id: sessionId,
      userId: userId,
      responses: [],
      startedAt: DateTime.now(),
      currentQuestionId: 'education_level', // Start with first question
      context: {},
      progressPercentage: 0.0,
    );

    return session;
  }

  Future<AssessmentSession> addResponse(
    AssessmentSession session,
    String questionId,
    dynamic answer,
  ) async {
    final response = QuestionResponse(
      questionId: questionId,
      answer: answer,
      timestamp: DateTime.now(),
    );

    final updatedResponses = List<QuestionResponse>.from(session.responses);

    // Remove existing response for this question if any
    updatedResponses.removeWhere((r) => r.questionId == questionId);
    updatedResponses.add(response);

    // Update context based on answer
    final updatedContext = Map<String, dynamic>.from(session.context);
    updatedContext[questionId] = answer;

    // Determine next question
    final nextQuestionId = getNextQuestionId(
      questionId,
      answer,
      updatedContext,
    );

    // Calculate progress
    final totalQuestions = _getTotalExpectedQuestions(updatedContext);
    final progress = (updatedResponses.length / totalQuestions * 100).clamp(
      0.0,
      100.0,
    );

    final updatedSession = session.copyWith(
      responses: updatedResponses,
      currentQuestionId: nextQuestionId ?? 'completed',
      context: updatedContext,
      progressPercentage: progress,
      completedAt: nextQuestionId == null ? DateTime.now() : null,
    );

    return updatedSession;
  }

  int _getTotalExpectedQuestions(Map<String, dynamic> context) {
    // Base questions that everyone gets
    int baseQuestions =
        11; // education_level, career_interests, work_mode_preference, salary_expectations, location_preference, career_goals, personality_type, work_style_preference, learning_preference, motivation_factors, skill_assessment, career_challenges, ideal_company_size

    // Add conditional questions based on user's path
    if (context['education_level'] == 'Class 10' ||
        context['education_level'] == 'Class 12') {
      baseQuestions += 1; // stream_selection
    }
    if (context['education_level'] == 'Working Professional') {
      baseQuestions += 1; // work_experience
    }

    baseQuestions += 1; // technical_background (everyone gets this)

    if (context['technical_background'] == 'Yes') {
      baseQuestions += 1; // programming_languages
    }

    // Industry-specific questions (one of these based on interests)
    final interests = context['career_interests'];
    if (interests != null && interests is List) {
      if (interests.any(
        (interest) =>
            ['Software Development', 'Data Science'].contains(interest),
      )) {
        baseQuestions += 1; // tech_specialization
      } else if (interests.any(
        (interest) =>
            ['Finance', 'Marketing', 'Entrepreneurship'].contains(interest),
      )) {
        baseQuestions += 1; // business_role_type
      } else if (interests.any((interest) => ['Design'].contains(interest))) {
        baseQuestions += 1; // creative_domain
      } else if (interests.any(
        (interest) => ['Healthcare'].contains(interest),
      )) {
        baseQuestions += 1; // healthcare_path
      }
    }

    return baseQuestions;
  } // Question database

  AdaptiveQuestion? getQuestionById(String id) {
    final questions = _getAllQuestions();
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  List<AdaptiveQuestion> _getAllQuestions() {
    return [
      AdaptiveQuestion(
        id: 'education_level',
        text: 'What\'s your current education level?',
        subtitle: 'This helps us understand your starting point',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(id: '1', text: 'Class 10', value: 'Class 10'),
          QuestionOption(id: '2', text: 'Class 12', value: 'Class 12'),
          QuestionOption(id: '3', text: 'Diploma', value: 'Diploma'),
          QuestionOption(
            id: '4',
            text: 'Undergraduate',
            value: 'Undergraduate',
          ),
          QuestionOption(id: '5', text: 'Postgraduate', value: 'Postgraduate'),
          QuestionOption(
            id: '6',
            text: 'Working Professional',
            value: 'Working Professional',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'stream_selection',
        text: 'Which stream are you in or did you study?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(id: '1', text: 'Science (PCM/PCB)', value: 'Science'),
          QuestionOption(id: '2', text: 'Commerce', value: 'Commerce'),
          QuestionOption(id: '3', text: 'Arts/Humanities', value: 'Arts'),
          QuestionOption(
            id: '4',
            text: 'Computer Applications',
            value: 'Computer Applications',
          ),
          QuestionOption(id: '5', text: 'Engineering', value: 'Engineering'),
          QuestionOption(id: '6', text: 'Other', value: 'Other'),
        ],
      ),

      AdaptiveQuestion(
        id: 'work_experience',
        text: 'How many years of work experience do you have?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Less than 1 year',
            value: 'Less than 1 year',
          ),
          QuestionOption(id: '2', text: '1-2 years', value: '1-2 years'),
          QuestionOption(id: '3', text: '3-5 years', value: '3-5 years'),
          QuestionOption(
            id: '4',
            text: 'More than 5 years',
            value: 'More than 5 years',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'technical_background',
        text: 'Do you have any technical/programming background?',
        subtitle:
            'This includes any coding, web development, or technical skills',
        type: QuestionType.yesNo,
        options: [
          QuestionOption(id: '1', text: 'Yes', value: 'Yes'),
          QuestionOption(id: '2', text: 'No', value: 'No'),
        ],
      ),

      AdaptiveQuestion(
        id: 'programming_languages',
        text:
            'Which programming languages or technologies are you familiar with?',
        type: QuestionType.multipleChoice,
        maxSelections: 5,
        options: [
          QuestionOption(id: '1', text: 'Python', value: 'Python'),
          QuestionOption(id: '2', text: 'Java', value: 'Java'),
          QuestionOption(id: '3', text: 'JavaScript', value: 'JavaScript'),
          QuestionOption(id: '4', text: 'C/C++', value: 'C/C++'),
          QuestionOption(id: '5', text: 'HTML/CSS', value: 'HTML/CSS'),
          QuestionOption(id: '6', text: 'SQL', value: 'SQL'),
          QuestionOption(
            id: '7',
            text: 'React/Flutter',
            value: 'React/Flutter',
          ),
          QuestionOption(
            id: '8',
            text: 'Machine Learning',
            value: 'Machine Learning',
          ),
          QuestionOption(id: '9', text: 'Other', value: 'Other'),
        ],
      ),

      AdaptiveQuestion(
        id: 'career_interests',
        text: 'What areas interest you the most?',
        subtitle: 'Select up to 3 options',
        type: QuestionType.multipleChoice,
        maxSelections: 3,
        options: [
          QuestionOption(
            id: '1',
            text: 'Software Development',
            value: 'Software Development',
          ),
          QuestionOption(
            id: '2',
            text: 'Data Science & Analytics',
            value: 'Data Science',
          ),
          QuestionOption(id: '3', text: 'Design (UI/UX)', value: 'Design'),
          QuestionOption(id: '4', text: 'Finance & Banking', value: 'Finance'),
          QuestionOption(
            id: '5',
            text: 'Marketing & Sales',
            value: 'Marketing',
          ),
          QuestionOption(id: '6', text: 'Healthcare', value: 'Healthcare'),
          QuestionOption(
            id: '7',
            text: 'Education & Training',
            value: 'Education',
          ),
          QuestionOption(
            id: '8',
            text: 'Entrepreneurship',
            value: 'Entrepreneurship',
          ),
          QuestionOption(
            id: '9',
            text: 'Research & Development',
            value: 'Research',
          ),
          QuestionOption(
            id: '10',
            text: 'Government & Public Service',
            value: 'Government',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'work_mode_preference',
        text: 'What\'s your preferred work mode?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Remote (Work from home)',
            value: 'Remote',
          ),
          QuestionOption(id: '2', text: 'On-site (Office)', value: 'On-site'),
          QuestionOption(
            id: '3',
            text: 'Hybrid (Mix of both)',
            value: 'Hybrid',
          ),
          QuestionOption(
            id: '4',
            text: 'No preference',
            value: 'No preference',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'salary_expectations',
        text: 'What are your salary expectations? (Annual)',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(id: '1', text: 'Below ₹3 LPA', value: 'Below 3 LPA'),
          QuestionOption(id: '2', text: '₹3-6 LPA', value: '3-6 LPA'),
          QuestionOption(id: '3', text: '₹6-10 LPA', value: '6-10 LPA'),
          QuestionOption(id: '4', text: '₹10-15 LPA', value: '10-15 LPA'),
          QuestionOption(id: '5', text: 'Above ₹15 LPA', value: 'Above 15 LPA'),
          QuestionOption(id: '6', text: 'Not sure yet', value: 'Not sure'),
        ],
      ),

      AdaptiveQuestion(
        id: 'location_preference',
        text: 'Which cities would you prefer to work in?',
        subtitle: 'Select up to 3 cities',
        type: QuestionType.multipleChoice,
        maxSelections: 3,
        options: [
          QuestionOption(id: '1', text: 'Bangalore', value: 'Bangalore'),
          QuestionOption(id: '2', text: 'Mumbai', value: 'Mumbai'),
          QuestionOption(id: '3', text: 'Delhi/NCR', value: 'Delhi NCR'),
          QuestionOption(id: '4', text: 'Pune', value: 'Pune'),
          QuestionOption(id: '5', text: 'Hyderabad', value: 'Hyderabad'),
          QuestionOption(id: '6', text: 'Chennai', value: 'Chennai'),
          QuestionOption(id: '7', text: 'Kolkata', value: 'Kolkata'),
          QuestionOption(id: '8', text: 'Ahmedabad', value: 'Ahmedabad'),
          QuestionOption(
            id: '9',
            text: 'International',
            value: 'International',
          ),
          QuestionOption(
            id: '10',
            text: 'Tier 2/3 cities',
            value: 'Tier 2/3 cities',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'career_goals',
        text: 'What\'s your primary career goal for the next 2-3 years?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(id: '1', text: 'Get my first job', value: 'First job'),
          QuestionOption(
            id: '2',
            text: 'Switch to a better role',
            value: 'Switch role',
          ),
          QuestionOption(
            id: '3',
            text: 'Get promoted in current company',
            value: 'Promotion',
          ),
          QuestionOption(
            id: '4',
            text: 'Start my own business',
            value: 'Entrepreneurship',
          ),
          QuestionOption(
            id: '5',
            text: 'Learn new skills',
            value: 'Skill development',
          ),
          QuestionOption(
            id: '6',
            text: 'Change career field entirely',
            value: 'Career change',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'personality_type',
        text: 'Which personality type best describes you?',
        subtitle: 'This helps us understand your work style preferences',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Analytical & Detail-oriented',
            value: 'Analytical',
          ),
          QuestionOption(
            id: '2',
            text: 'Creative & Innovative',
            value: 'Creative',
          ),
          QuestionOption(
            id: '3',
            text: 'People-focused & Collaborative',
            value: 'People-focused',
          ),
          QuestionOption(
            id: '4',
            text: 'Results-driven & Goal-oriented',
            value: 'Results-driven',
          ),
          QuestionOption(
            id: '5',
            text: 'Practical & Hands-on',
            value: 'Practical',
          ),
          QuestionOption(
            id: '6',
            text: 'Strategic & Big-picture thinker',
            value: 'Strategic',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'work_style_preference',
        text: 'How do you prefer to work?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Independently with minimal supervision',
            value: 'Independent',
          ),
          QuestionOption(
            id: '2',
            text: 'In small, close-knit teams',
            value: 'Small teams',
          ),
          QuestionOption(
            id: '3',
            text: 'In large, diverse teams',
            value: 'Large teams',
          ),
          QuestionOption(
            id: '4',
            text: 'Leading and managing others',
            value: 'Leadership',
          ),
          QuestionOption(
            id: '5',
            text: 'Mix of individual and team work',
            value: 'Mixed',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'learning_preference',
        text: 'How do you learn best?',
        type: QuestionType.multipleChoice,
        maxSelections: 2,
        options: [
          QuestionOption(
            id: '1',
            text: 'Hands-on practice and experimentation',
            value: 'Hands-on',
          ),
          QuestionOption(
            id: '2',
            text: 'Reading and research',
            value: 'Reading',
          ),
          QuestionOption(
            id: '3',
            text: 'Watching videos and tutorials',
            value: 'Videos',
          ),
          QuestionOption(
            id: '4',
            text: 'Mentorship and guidance',
            value: 'Mentorship',
          ),
          QuestionOption(
            id: '5',
            text: 'Group discussions and collaboration',
            value: 'Group learning',
          ),
          QuestionOption(
            id: '6',
            text: 'Structured courses and certifications',
            value: 'Structured learning',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'motivation_factors',
        text: 'What motivates you most in your career?',
        subtitle: 'Select your top 3 motivators',
        type: QuestionType.multipleChoice,
        maxSelections: 3,
        options: [
          QuestionOption(
            id: '1',
            text: 'Making a positive impact on society',
            value: 'Social impact',
          ),
          QuestionOption(
            id: '2',
            text: 'Financial success and stability',
            value: 'Financial success',
          ),
          QuestionOption(
            id: '3',
            text: 'Creative expression and innovation',
            value: 'Creativity',
          ),
          QuestionOption(
            id: '4',
            text: 'Recognition and professional growth',
            value: 'Recognition',
          ),
          QuestionOption(
            id: '5',
            text: 'Work-life balance and flexibility',
            value: 'Work-life balance',
          ),
          QuestionOption(
            id: '6',
            text: 'Learning and skill development',
            value: 'Learning',
          ),
          QuestionOption(
            id: '7',
            text: 'Building relationships and networking',
            value: 'Relationships',
          ),
          QuestionOption(
            id: '8',
            text: 'Solving complex problems',
            value: 'Problem solving',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'tech_specialization',
        text: 'Which technology area interests you most?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Frontend Development (UI/UX)',
            value: 'Frontend',
          ),
          QuestionOption(
            id: '2',
            text: 'Backend Development (Server-side)',
            value: 'Backend',
          ),
          QuestionOption(
            id: '3',
            text: 'Full-stack Development',
            value: 'Fullstack',
          ),
          QuestionOption(
            id: '4',
            text: 'Mobile App Development',
            value: 'Mobile',
          ),
          QuestionOption(
            id: '5',
            text: 'Data Science & Machine Learning',
            value: 'Data Science',
          ),
          QuestionOption(
            id: '6',
            text: 'DevOps & Cloud Computing',
            value: 'DevOps',
          ),
          QuestionOption(
            id: '7',
            text: 'Cybersecurity',
            value: 'Cybersecurity',
          ),
          QuestionOption(
            id: '8',
            text: 'Game Development',
            value: 'Game Development',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'business_role_type',
        text: 'Which business function appeals to you most?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Financial Analysis & Investment',
            value: 'Finance',
          ),
          QuestionOption(
            id: '2',
            text: 'Digital Marketing & Growth',
            value: 'Marketing',
          ),
          QuestionOption(
            id: '3',
            text: 'Sales & Client Relations',
            value: 'Sales',
          ),
          QuestionOption(
            id: '4',
            text: 'Business Strategy & Consulting',
            value: 'Strategy',
          ),
          QuestionOption(
            id: '5',
            text: 'Operations & Supply Chain',
            value: 'Operations',
          ),
          QuestionOption(
            id: '6',
            text: 'Human Resources & Talent',
            value: 'HR',
          ),
          QuestionOption(id: '7', text: 'Product Management', value: 'Product'),
        ],
      ),

      AdaptiveQuestion(
        id: 'creative_domain',
        text: 'Which creative field interests you most?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'User Experience (UX) Design',
            value: 'UX Design',
          ),
          QuestionOption(
            id: '2',
            text: 'User Interface (UI) Design',
            value: 'UI Design',
          ),
          QuestionOption(
            id: '3',
            text: 'Graphic Design & Branding',
            value: 'Graphic Design',
          ),
          QuestionOption(
            id: '4',
            text: 'Animation & Motion Graphics',
            value: 'Animation',
          ),
          QuestionOption(
            id: '5',
            text: 'Content Creation & Writing',
            value: 'Content Creation',
          ),
          QuestionOption(
            id: '6',
            text: 'Photography & Videography',
            value: 'Photography',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'healthcare_path',
        text: 'Which healthcare area interests you?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Clinical Practice (Doctor/Nurse)',
            value: 'Clinical',
          ),
          QuestionOption(
            id: '2',
            text: 'Healthcare Technology',
            value: 'HealthTech',
          ),
          QuestionOption(id: '3', text: 'Medical Research', value: 'Research'),
          QuestionOption(
            id: '4',
            text: 'Healthcare Administration',
            value: 'Administration',
          ),
          QuestionOption(
            id: '5',
            text: 'Public Health & Policy',
            value: 'Public Health',
          ),
          QuestionOption(
            id: '6',
            text: 'Pharmaceutical Industry',
            value: 'Pharmaceutical',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'skill_assessment',
        text: 'Rate your confidence in these areas (1-5 scale)',
        subtitle: '1 = Beginner, 5 = Expert',
        type: QuestionType.rating,
        minRating: 1,
        maxRating: 5,
        options: [
          QuestionOption(
            id: '1',
            text: 'Communication Skills',
            value: 'communication',
          ),
          QuestionOption(
            id: '2',
            text: 'Problem Solving',
            value: 'problem_solving',
          ),
          QuestionOption(id: '3', text: 'Technical Skills', value: 'technical'),
          QuestionOption(id: '4', text: 'Leadership', value: 'leadership'),
          QuestionOption(id: '5', text: 'Teamwork', value: 'teamwork'),
        ],
      ),

      AdaptiveQuestion(
        id: 'career_challenges',
        text: 'What do you see as your biggest career challenge?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Lack of relevant experience',
            value: 'Experience',
          ),
          QuestionOption(
            id: '2',
            text: 'Limited technical skills',
            value: 'Technical skills',
          ),
          QuestionOption(
            id: '3',
            text: 'Networking and connections',
            value: 'Networking',
          ),
          QuestionOption(
            id: '4',
            text: 'Interview and communication skills',
            value: 'Communication',
          ),
          QuestionOption(
            id: '5',
            text: 'Unclear career direction',
            value: 'Direction',
          ),
          QuestionOption(
            id: '6',
            text: 'Competition in the job market',
            value: 'Competition',
          ),
          QuestionOption(
            id: '7',
            text: 'Work-life balance concerns',
            value: 'Work-life balance',
          ),
        ],
      ),

      AdaptiveQuestion(
        id: 'ideal_company_size',
        text: 'What size company would you prefer to work for?',
        type: QuestionType.singleChoice,
        options: [
          QuestionOption(
            id: '1',
            text: 'Startup (1-50 employees)',
            value: 'Startup',
          ),
          QuestionOption(
            id: '2',
            text: 'Small company (51-200 employees)',
            value: 'Small',
          ),
          QuestionOption(
            id: '3',
            text: 'Medium company (201-1000 employees)',
            value: 'Medium',
          ),
          QuestionOption(
            id: '4',
            text: 'Large corporation (1000+ employees)',
            value: 'Large',
          ),
          QuestionOption(
            id: '5',
            text: 'Government/Public sector',
            value: 'Government',
          ),
          QuestionOption(
            id: '6',
            text: 'No preference',
            value: 'No preference',
          ),
        ],
      ),
    ];
  }

  // Generate personalized career guidance
  Map<String, dynamic> generateAssessmentData(AssessmentSession session) {
    final answers = session.getAllAnswers();
    final context = session.context;

    return {
      'education': answers['education_level'],
      'stream': answers['stream_selection'],
      'work_experience': answers['work_experience'],
      'technical_background': answers['technical_background'],
      'programming_languages': answers['programming_languages'],
      'career_interests': answers['career_interests'],
      'work_mode': answers['work_mode_preference'],
      'salary_expectations': answers['salary_expectations'],
      'location_preference': answers['location_preference'],
      'career_goals': answers['career_goals'],
      'personality_type': answers['personality_type'],
      'work_style_preference': answers['work_style_preference'],
      'learning_preference': answers['learning_preference'],
      'motivation_factors': answers['motivation_factors'],
      'tech_specialization': answers['tech_specialization'],
      'business_role_type': answers['business_role_type'],
      'creative_domain': answers['creative_domain'],
      'healthcare_path': answers['healthcare_path'],
      'skill_ratings': answers['skill_assessment'],
      'career_challenges': answers['career_challenges'],
      'ideal_company_size': answers['ideal_company_size'],
      'session_metadata': {
        'session_id': session.id,
        'duration_minutes': session.completedAt
            ?.difference(session.startedAt)
            .inMinutes,
        'total_questions': session.responses.length,
        'adaptive_path': context.keys.toList(),
      },
    };
  }

  String buildPersonalizedPrompt(AssessmentSession session) {
    final answers = session.getAllAnswers();

    final prompt = StringBuffer();
    prompt.writeln(
      'Generate personalized career guidance based on this adaptive assessment:',
    );
    prompt.writeln('');

    // Basic info
    prompt.writeln('PROFILE:');
    prompt.writeln(
      '- Education: ${answers['education_level'] ?? 'Not specified'}',
    );
    if (answers['stream_selection'] != null) {
      prompt.writeln('- Stream: ${answers['stream_selection']}');
    }
    if (answers['work_experience'] != null) {
      prompt.writeln('- Experience: ${answers['work_experience']}');
    }
    prompt.writeln('');

    // Technical background
    if (answers['technical_background'] == 'Yes' &&
        answers['programming_languages'] != null) {
      prompt.writeln('TECHNICAL SKILLS:');
      if (answers['programming_languages'] is List) {
        prompt.writeln(
          '- Languages: ${(answers['programming_languages'] as List).join(', ')}',
        );
      }
      prompt.writeln('');
    }

    // Career interests
    if (answers['career_interests'] != null) {
      prompt.writeln('INTERESTS:');
      if (answers['career_interests'] is List) {
        prompt.writeln(
          '- Areas: ${(answers['career_interests'] as List).join(', ')}',
        );
      }
      prompt.writeln('');
    }

    // Preferences
    prompt.writeln('PREFERENCES:');
    if (answers['work_mode_preference'] != null) {
      prompt.writeln('- Work Mode: ${answers['work_mode_preference']}');
    }
    if (answers['salary_expectations'] != null) {
      prompt.writeln('- Salary: ${answers['salary_expectations']}');
    }
    if (answers['location_preference'] != null &&
        answers['location_preference'] is List) {
      prompt.writeln(
        '- Locations: ${(answers['location_preference'] as List).join(', ')}',
      );
    }
    prompt.writeln('');

    // Goals and personality
    if (answers['career_goals'] != null) {
      prompt.writeln('GOALS & PERSONALITY:');
      prompt.writeln('- Primary Goal: ${answers['career_goals']}');
      if (answers['personality_type'] != null) {
        prompt.writeln('- Personality Type: ${answers['personality_type']}');
      }
      if (answers['work_style_preference'] != null) {
        prompt.writeln('- Work Style: ${answers['work_style_preference']}');
      }
      prompt.writeln('');
    }

    // Learning and motivation
    if (answers['learning_preference'] != null ||
        answers['motivation_factors'] != null) {
      prompt.writeln('LEARNING & MOTIVATION:');
      if (answers['learning_preference'] != null &&
          answers['learning_preference'] is List) {
        prompt.writeln(
          '- Learning Style: ${(answers['learning_preference'] as List).join(', ')}',
        );
      }
      if (answers['motivation_factors'] != null &&
          answers['motivation_factors'] is List) {
        prompt.writeln(
          '- Key Motivators: ${(answers['motivation_factors'] as List).join(', ')}',
        );
      }
      prompt.writeln('');
    }

    // Specialization based on interests
    if (answers['tech_specialization'] != null) {
      prompt.writeln('TECHNICAL SPECIALIZATION:');
      prompt.writeln('- Preferred Area: ${answers['tech_specialization']}');
      prompt.writeln('');
    }
    if (answers['business_role_type'] != null) {
      prompt.writeln('BUSINESS SPECIALIZATION:');
      prompt.writeln('- Preferred Function: ${answers['business_role_type']}');
      prompt.writeln('');
    }
    if (answers['creative_domain'] != null) {
      prompt.writeln('CREATIVE SPECIALIZATION:');
      prompt.writeln('- Preferred Domain: ${answers['creative_domain']}');
      prompt.writeln('');
    }
    if (answers['healthcare_path'] != null) {
      prompt.writeln('HEALTHCARE SPECIALIZATION:');
      prompt.writeln('- Preferred Path: ${answers['healthcare_path']}');
      prompt.writeln('');
    }

    // Challenges and company preferences
    if (answers['career_challenges'] != null ||
        answers['ideal_company_size'] != null) {
      prompt.writeln('CHALLENGES & PREFERENCES:');
      if (answers['career_challenges'] != null) {
        prompt.writeln('- Main Challenge: ${answers['career_challenges']}');
      }
      if (answers['ideal_company_size'] != null) {
        prompt.writeln(
          '- Company Size Preference: ${answers['ideal_company_size']}',
        );
      }
      prompt.writeln('');
    }

    prompt.writeln('Please provide:');
    prompt.writeln(
      '1. 3-4 most suitable career paths with specific role names',
    );
    prompt.writeln('2. Skills to develop for each path with timeline');
    prompt.writeln('3. Relevant Indian certifications and courses');
    prompt.writeln('4. Practical next steps for the next 3-6 months');
    prompt.writeln('5. Industry insights and job market trends in India');
    prompt.writeln('6. Specific companies to target');
    prompt.writeln('');
    prompt.writeln(
      'Make the advice actionable and specific to the Indian job market.',
    );

    return prompt.toString();
  }
}
