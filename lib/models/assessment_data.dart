class AssessmentData {
  final String? education;
  final String? stream;
  final String? workMode;
  final String favoriteSubjects;
  final String technicalSkills;
  final String softSkills;
  final String interests;
  final String targetRoles;
  final String preferredIndustry;
  final String preferredLocation;
  final String expectedSalary;

  AssessmentData({
    this.education,
    this.stream,
    this.workMode,
    required this.favoriteSubjects,
    required this.technicalSkills,
    required this.softSkills,
    required this.interests,
    required this.targetRoles,
    required this.preferredIndustry,
    required this.preferredLocation,
    required this.expectedSalary,
  });

  factory AssessmentData.fromJson(Map<String, dynamic> json) {
    return AssessmentData(
      education: json['education'],
      stream: json['stream'],
      workMode: json['work_mode'],
      favoriteSubjects: json['favorite_subjects'] ?? '',
      technicalSkills: json['technical_skills'] ?? '',
      softSkills: json['soft_skills'] ?? '',
      interests: json['interests'] ?? '',
      targetRoles: json['target_roles'] ?? '',
      preferredIndustry: json['preferred_industry'] ?? '',
      preferredLocation: json['preferred_location'] ?? '',
      expectedSalary: json['expected_salary'] ?? '',
    );
  }

  factory AssessmentData.fromAdaptiveSession(dynamic session) {
    final answers = session.getAllAnswers();

    // Helper function to convert list to string
    String listToString(dynamic value) {
      if (value is List) {
        return value.join(', ');
      }
      return value?.toString() ?? '';
    }

    return AssessmentData(
      education: answers['education_level'],
      stream: answers['stream_selection'],
      workMode: answers['work_mode_preference'],
      favoriteSubjects: listToString(answers['career_interests']),
      technicalSkills: listToString(answers['programming_languages']),
      softSkills: answers['skill_assessment']?.toString() ?? '',
      interests: listToString(answers['career_interests']),
      targetRoles: answers['career_goals']?.toString() ?? '',
      preferredIndustry: listToString(answers['career_interests']),
      preferredLocation: listToString(answers['location_preference']),
      expectedSalary: answers['salary_expectations']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'education': education,
      'stream': stream,
      'work_mode': workMode,
      'favorite_subjects': favoriteSubjects,
      'technical_skills': technicalSkills,
      'soft_skills': softSkills,
      'interests': interests,
      'target_roles': targetRoles,
      'preferred_industry': preferredIndustry,
      'preferred_location': preferredLocation,
      'expected_salary': expectedSalary,
    };
  }

  String generatePrompt() {
    final buffer = StringBuffer();
    buffer.writeln(
      'Please provide career guidance based on the following assessment:',
    );

    if (education != null) buffer.writeln('Education Level: $education');
    if (stream != null) buffer.writeln('Stream/Field: $stream');
    if (workMode != null) buffer.writeln('Preferred Work Mode: $workMode');

    buffer.writeln('Favorite Subjects: $favoriteSubjects');
    buffer.writeln('Technical Skills: $technicalSkills');
    buffer.writeln('Soft Skills: $softSkills');
    buffer.writeln('Interests: $interests');
    buffer.writeln('Target Roles: $targetRoles');
    buffer.writeln('Preferred Industry: $preferredIndustry');
    buffer.writeln('Preferred Location: $preferredLocation');
    buffer.writeln('Expected Salary: $expectedSalary');

    buffer.writeln(
      '\nPlease provide specific career recommendations, required skills to develop, and actionable next steps.',
    );

    return buffer.toString();
  }

  bool get isValid {
    return favoriteSubjects.isNotEmpty &&
        technicalSkills.isNotEmpty &&
        softSkills.isNotEmpty &&
        interests.isNotEmpty &&
        targetRoles.isNotEmpty;
  }
}
