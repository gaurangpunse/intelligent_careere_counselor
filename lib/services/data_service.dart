import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/career_guidance.dart';

class DataService {
  static final DataService instance = DataService._();
  DataService._();

  final _supabase = Supabase.instance.client;

  // Career Guidance Operations
  Future<CareerGuidance> saveCareerGuidance(CareerGuidance guidance) async {
    try {
      final response = await _supabase
          .from('career_guidance')
          .insert(guidance.toInsert())
          .select()
          .single();

      return CareerGuidance.fromJson(response);
    } catch (e) {
      throw Exception('Failed to save career guidance: $e');
    }
  }

  Future<List<CareerGuidance>> getCareerGuidanceHistory(String userId) async {
    try {
      final response = await _supabase
          .from('career_guidance')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<CareerGuidance>((json) => CareerGuidance.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch career guidance history: $e');
    }
  }

  Future<CareerGuidance?> getLatestCareerGuidance(String userId) async {
    try {
      final response = await _supabase
          .from('career_guidance')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;
      return CareerGuidance.fromJson(response.first);
    } catch (e) {
      throw Exception('Failed to fetch latest career guidance: $e');
    }
  }

  Future<void> deleteCareerGuidance(String guidanceId) async {
    try {
      await _supabase.from('career_guidance').delete().eq('id', guidanceId);
    } catch (e) {
      throw Exception('Failed to delete career guidance: $e');
    }
  }

  // User Profile Operations
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        ...profileData,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getCareerGuidanceStats(String userId) async {
    try {
      final response = await _supabase
          .from('career_guidance')
          .select('id, created_at')
          .eq('user_id', userId);

      final totalGuidance = response.length;
      final now = DateTime.now();
      final thisMonth = response.where((item) {
        final createdAt = DateTime.parse(item['created_at']);
        return createdAt.year == now.year && createdAt.month == now.month;
      }).length;

      return {
        'total_guidance': totalGuidance,
        'this_month': thisMonth,
        'last_guidance': response.isNotEmpty
            ? DateTime.parse(response.first['created_at'])
            : null,
      };
    } catch (e) {
      throw Exception('Failed to fetch career guidance stats: $e');
    }
  }

  // Assessment Session Operations (using career_guidance table)
  Future<Map<String, dynamic>> saveAssessmentSession({
    required String userId,
    required Map<String, dynamic> sessionData,
    required Map<String, dynamic> recommendations,
  }) async {
    try {
      // Create prompt from session data
      final prompt = _generateAssessmentPrompt(sessionData);

      // Create response from recommendations
      final response = _generateAssessmentResponse(recommendations);

      final result = await _supabase
          .from('career_guidance')
          .insert({
            'user_id': userId,
            'prompt': prompt,
            'response': response,
            'assessment_data': {
              'session_data': sessionData,
              'recommendations': recommendations,
              'assessment_type': 'adaptive_assessment',
            },
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return result;
    } catch (e) {
      throw Exception('Failed to save assessment session: $e');
    }
  }

  String _generateAssessmentPrompt(Map<String, dynamic> sessionData) {
    final totalQuestions = sessionData['total_questions'] ?? 0;

    return 'Adaptive Career Assessment with $totalQuestions questions completed. '
        'Assessment responses cover areas including career interests, skills, '
        'personality traits, and professional preferences.';
  }

  String _generateAssessmentResponse(Map<String, dynamic> recommendations) {
    final careerPaths = recommendations['career_paths'] as List? ?? [];
    final companies = recommendations['target_companies'] as List? ?? [];

    String response = 'Career Assessment Results:\n\n';

    if (careerPaths.isNotEmpty) {
      response += 'Recommended Career Paths:\n';
      for (var path in careerPaths.take(3)) {
        response += '• ${path['title']} - ${path['description']}\n';
      }
      response += '\n';
    }

    if (companies.isNotEmpty) {
      response += 'Target Companies:\n';
      for (var company in companies.take(5)) {
        response += '• ${company['name']} - ${company['why_good_fit']}\n';
      }
    }

    return response;
  }

  Future<List<Map<String, dynamic>>> getAssessmentHistory(String userId) async {
    try {
      final response = await _supabase
          .from('career_guidance')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch assessment history: $e');
    }
  }

  Future<Map<String, dynamic>?> getLatestAssessment(String userId) async {
    try {
      final response = await _supabase
          .from('career_guidance')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;
      return response.first;
    } catch (e) {
      throw Exception('Failed to fetch latest assessment: $e');
    }
  }
}
