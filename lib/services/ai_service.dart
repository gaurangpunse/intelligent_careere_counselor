import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class AIService {
  AIService._();

  static final AIService instance = AIService._();

  static const String proxyEndpoint = String.fromEnvironment(
    'AI_PROXY_ENDPOINT',
    defaultValue: '',
  );

  static const String openaiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  // Configuration
  static const int maxRetries = 3;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration retryDelay = Duration(seconds: 2);

  Future<String> getCareerAdvice({
    required String prompt,
    required List<ChatMessage> history,
  }) async {
    try {
      return await _makeRequestWithRetry(prompt, history);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AI Service Error: $e');
      }
      return _getErrorResponse(e);
    }
  }

  Future<String> _makeRequestWithRetry(
    String prompt,
    List<ChatMessage> history,
  ) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await _makeRequest(prompt, history);
      } catch (e) {
        if (attempt == maxRetries) {
          rethrow;
        }

        if (kDebugMode) {
          debugPrint('Attempt $attempt failed: $e. Retrying...');
        }

        await Future.delayed(retryDelay * attempt);
      }
    }

    throw Exception('All retry attempts failed');
  }

  Future<String> _makeRequest(String prompt, List<ChatMessage> history) async {
    // Try proxy endpoint first
    if (proxyEndpoint.isNotEmpty) {
      try {
        return await _makeProxyRequest(prompt, history);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Proxy request failed: $e');
        }
        // Continue to try OpenAI direct if proxy fails
      }
    }

    // Try OpenAI direct
    if (openaiKey.isNotEmpty) {
      try {
        return await _makeOpenAIRequest(prompt, history);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('OpenAI direct request failed: $e');
        }
        rethrow;
      }
    }

    // Fall back to offline mode
    return _offlineHeuristic(prompt, history);
  }

  Future<String> _makeProxyRequest(
    String prompt,
    List<ChatMessage> history,
  ) async {
    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(proxyEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'messages': [
                ...history.map((m) => m.toJson()),
                {'role': 'user', 'content': _systemAugment(prompt)},
              ],
            }),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = data['reply'] as String?;

        if (reply == null || reply.isEmpty) {
          throw Exception('Empty response from proxy');
        }

        return reply;
      } else {
        throw HttpException(
          'Proxy returned ${response.statusCode}: ${response.body}',
          uri: Uri.parse(proxyEndpoint),
        );
      }
    } finally {
      client.close();
    }
  }

  Future<String> _makeOpenAIRequest(
    String prompt,
    List<ChatMessage> history,
  ) async {
    final client = http.Client();
    try {
      final body = {
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          ...history.map((m) => m.toJson()),
          {'role': 'user', 'content': _systemAugment(prompt)},
        ],
        'temperature': 0.3,
        'max_tokens': 1500,
      };

      final response = await client
          .post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $openaiKey',
              'User-Agent': 'Career-Counselling-App/1.0',
            },
            body: jsonEncode(body),
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;

        if (choices == null || choices.isEmpty) {
          throw Exception('No choices in OpenAI response');
        }

        final message = choices.first['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;

        if (content == null || content.isEmpty) {
          throw Exception('Empty content in OpenAI response');
        }

        return content;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid OpenAI API key');
      } else if (response.statusCode == 429) {
        throw Exception('OpenAI rate limit exceeded. Please try again later.');
      } else if (response.statusCode >= 500) {
        throw Exception('OpenAI server error. Please try again later.');
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorData?['error']?['message'] as String?;
        throw Exception('OpenAI API error: ${errorMessage ?? 'Unknown error'}');
      }
    } finally {
      client.close();
    }
  }

  String _getErrorResponse(dynamic error) {
    if (error.toString().contains('rate limit')) {
      return '''
I apologize, but I'm currently experiencing high demand. Please try again in a few moments.

In the meantime, here are some general career guidance tips:

**Key Steps for Career Development:**
• Identify your core strengths and interests
• Research in-demand skills in your field
• Build a portfolio showcasing your abilities
• Network with professionals in your target industry
• Keep learning and updating your skills

**Popular Career Paths in India:**
• Technology: Software Development, Data Science, Cybersecurity
• Business: Digital Marketing, Business Analysis, Project Management
• Creative: UI/UX Design, Content Creation, Digital Media

Please retry your assessment in a few minutes for personalized guidance.
''';
    }

    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return '''
I'm having trouble connecting to provide personalized guidance right now.

Here's some immediate career advice:

**Essential Skills for Any Career:**
• Communication and interpersonal skills
• Problem-solving and critical thinking
• Digital literacy and adaptability
• Time management and organization

**Next Steps You Can Take:**
1. Update your LinkedIn profile
2. Create a portfolio of your work
3. Identify 3-5 companies you'd like to work for
4. Set up job alerts on major job boards
5. Start networking in your field of interest

Please check your internet connection and try again.
''';
    }

    return _offlineHeuristic('', []);
  }

  String get _systemPrompt =>
      '''You are an expert Indian career counsellor with deep knowledge of the Indian job market, global opportunities, and educational pathways. 

Provide structured, actionable career guidance that includes:
1. 2-3 specific role recommendations with reasoning
2. Required skills and relevant certifications (prioritize Indian institutions)
3. Practical project ideas for portfolio building
4. 4-week learning plan with specific resources
5. Job market outlook in India and globally
6. Specific companies and next steps

Keep responses comprehensive but concise. Focus on practical, achievable advice.''';

  String _systemAugment(String userPrompt) {
    return '''$userPrompt

Please provide a comprehensive career guidance response covering:
- Best-fit career roles based on the assessment
- Skills gap analysis and development plan
- Portfolio project recommendations
- Learning pathway with timeline
- Industry insights and job market trends
- Actionable next steps for career advancement''';
  }

  String _offlineHeuristic(String prompt, List<ChatMessage> history) {
    final p = prompt.toLowerCase();
    final roles = <String>[];
    final skills = <String>[];
    final certifications = <String>[];

    // Analyze prompt for career indicators
    if (p.contains('python') ||
        p.contains('coding') ||
        p.contains('programming') ||
        p.contains('software')) {
      roles.addAll([
        'Software Developer',
        'Backend Developer',
        'Full Stack Developer',
      ]);
      skills.addAll([
        'Python/Java/JavaScript',
        'Database Management',
        'API Development',
      ]);
      certifications.addAll([
        'AWS Cloud Practitioner',
        'Google Cloud Associate',
        'Oracle Java Certification',
      ]);
    }

    if (p.contains('data') ||
        p.contains('analytics') ||
        p.contains('science')) {
      roles.addAll([
        'Data Analyst',
        'Data Scientist',
        'Business Intelligence Analyst',
      ]);
      skills.addAll(['SQL', 'Python/R', 'Tableau/Power BI', 'Statistics']);
      certifications.addAll([
        'Google Data Analytics',
        'Microsoft Power BI',
        'Tableau Desktop Specialist',
      ]);
    }

    if (p.contains('design') ||
        p.contains('ui') ||
        p.contains('ux') ||
        p.contains('creative')) {
      roles.addAll(['UI/UX Designer', 'Product Designer', 'Graphic Designer']);
      skills.addAll([
        'Figma/Adobe XD',
        'User Research',
        'Prototyping',
        'Visual Design',
      ]);
      certifications.addAll([
        'Google UX Design',
        'Adobe Certified Expert',
        'HFI CUA Certification',
      ]);
    }

    if (p.contains('marketing') ||
        p.contains('digital') ||
        p.contains('social media')) {
      roles.addAll([
        'Digital Marketing Specialist',
        'Content Marketer',
        'SEO Specialist',
      ]);
      skills.addAll(['Google Ads', 'SEO/SEM', 'Content Strategy', 'Analytics']);
      certifications.addAll([
        'Google Ads Certification',
        'HubSpot Content Marketing',
        'Facebook Blueprint',
      ]);
    }

    if (p.contains('finance') ||
        p.contains('accounting') ||
        p.contains('investment')) {
      roles.addAll([
        'Financial Analyst',
        'Investment Analyst',
        'Risk Management Specialist',
      ]);
      skills.addAll([
        'Financial Modeling',
        'Excel/VBA',
        'Risk Analysis',
        'Bloomberg Terminal',
      ]);
      certifications.addAll(['CFA', 'FRM', 'ACCA', 'Chartered Accountant']);
    }

    // Default roles if no specific indicators found
    if (roles.isEmpty) {
      roles.addAll([
        'Business Analyst',
        'Project Coordinator',
        'Operations Specialist',
      ]);
      skills.addAll([
        'Communication',
        'Project Management',
        'Data Analysis',
        'Process Improvement',
      ]);
      certifications.addAll([
        'PMP',
        'Agile/Scrum Master',
        'Google Analytics',
        'Microsoft Office Specialist',
      ]);
    }

    return '''
**🎯 Recommended Career Paths:**
${roles.take(3).map((role) => '• $role').join('\n')}

**🛠️ Key Skills to Develop:**
${skills.take(4).map((skill) => '• $skill').join('\n')}

**📜 Relevant Certifications:**
${certifications.take(3).map((cert) => '• $cert').join('\n')}

**💼 Portfolio Project Ideas:**
• Create a personal website showcasing your skills
• Develop 2-3 projects relevant to your target role
• Contribute to open-source projects or volunteer work
• Document your learning journey on LinkedIn/GitHub

**📅 4-Week Learning Plan:**
• **Week 1:** Foundation skills + industry research
• **Week 2:** Hands-on projects + online courses
• **Week 3:** Portfolio development + networking
• **Week 4:** Job applications + interview preparation

**📈 Job Market Outlook:**
The Indian job market is showing strong growth in technology, digital services, and data-driven roles. Remote work opportunities have expanded significantly, offering global exposure.

**🏢 Target Companies:**
Consider both startups (for growth) and established companies (for stability). Focus on companies like TCS, Infosys, Wipro, Accenture for traditional roles, or explore emerging startups in your domain.

**⚡ Immediate Next Steps:**
1. Update your LinkedIn profile with relevant keywords
2. Set up job alerts on Naukri.com, LinkedIn, and Indeed
3. Join professional communities in your field
4. Start networking with industry professionals
5. Begin working on your first portfolio project

*This guidance is based on general market trends. For personalized advice, please ensure you have a stable internet connection and try the assessment again.*
''';
  }
}
