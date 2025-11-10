import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../models/chat_message.dart';
import '../models/career_guidance.dart';
import '../models/assessment_data.dart';
import 'career_guidance_results_page.dart';

class CareerFormView extends StatefulWidget {
  const CareerFormView({super.key});

  @override
  State<CareerFormView> createState() => _CareerFormViewState();
}

class _CareerFormViewState extends State<CareerFormView> {
  final _formKey = GlobalKey<FormState>();
  String? _education;
  String? _stream;
  String? _workMode;

  final _favSubjectsCtrl = TextEditingController();
  final _techSkillsCtrl = TextEditingController();
  final _softSkillsCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();
  final _targetRolesCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _constraintsCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  bool _loading = false;
  String? _guidance;

  @override
  void dispose() {
    _favSubjectsCtrl.dispose();
    _techSkillsCtrl.dispose();
    _softSkillsCtrl.dispose();
    _interestsCtrl.dispose();
    _targetRolesCtrl.dispose();
    _industryCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _constraintsCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  String _buildPrompt() {
    final b = StringBuffer();
    b.writeln('Generate career guidance based on this questionnaire:');
    b.writeln('Education level: ${_education ?? "-"}');
    b.writeln('Stream: ${_stream ?? "-"}');
    b.writeln('Favourite subjects: ${_favSubjectsCtrl.text}');
    b.writeln('Technical skills: ${_techSkillsCtrl.text}');
    b.writeln('Soft skills: ${_softSkillsCtrl.text}');
    b.writeln('Interests: ${_interestsCtrl.text}');
    b.writeln('Target roles: ${_targetRolesCtrl.text}');
    b.writeln('Preferred industry: ${_industryCtrl.text}');
    b.writeln('Preferred location: ${_locationCtrl.text}');
    b.writeln('Work mode: ${_workMode ?? "-"}');
    b.writeln('Salary expectation: ${_salaryCtrl.text}');
    b.writeln('Constraints: ${_constraintsCtrl.text}');
    b.writeln('Portfolio/GitHub: ${_portfolioCtrl.text}');
    b.writeln('');
    b.writeln('Output structure:');
    b.writeln('• 2–3 best-fit roles with short reasoning');
    b.writeln('• Skills to build and relevant Indian/global certifications');
    b.writeln('• Starter projects and portfolio ideas');
    b.writeln('• 4-week learning plan');
    b.writeln(
      '• Job outlook in India & globally, suggested companies, and next steps',
    );
    return b.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _guidance = null;
    });

    try {
      final prompt = _buildPrompt();
      final advice = await AIService.instance.getCareerAdvice(
        prompt: prompt,
        history: const <ChatMessage>[],
      );

      // Create assessment data from form
      final assessmentData = AssessmentData(
        education: _education,
        stream: _stream,
        workMode: _workMode,
        favoriteSubjects: _favSubjectsCtrl.text,
        technicalSkills: _techSkillsCtrl.text,
        softSkills: _softSkillsCtrl.text,
        interests: _interestsCtrl.text,
        targetRoles: _targetRolesCtrl.text,
        preferredIndustry: _industryCtrl.text,
        preferredLocation: _locationCtrl.text,
        expectedSalary: _salaryCtrl.text,
      );

      // Create career guidance object
      final guidance = CareerGuidance(
        id: '', // Will be set by Supabase
        userId:
            AuthService.instance.userId ?? 'anonymous', // Using real user ID
        prompt: prompt,
        response: advice,
        assessmentData: assessmentData.toJson(),
        createdAt: DateTime.now(),
      );

      // Navigate to results page
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CareerGuidanceResultsPage(
              guidance: guidance,
              isNewGuidance: true,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _guidance = 'Sorry, something went wrong: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 1000.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Guide – Questionnaire'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ...existing code inside Column...
                      const SizedBox(height: 12),
                      Wrap(
                        runSpacing: 12,
                        spacing: 12,
                        children: [
                          _dropdown(
                            label: 'Education level *',
                            value: _education,
                            items: const [
                              'Class 10',
                              'Class 12',
                              'Diploma',
                              'Undergraduate',
                              'Postgraduate',
                              'Working Professional',
                            ],
                            onChanged: (v) => setState(() => _education = v),
                          ),
                          _dropdown(
                            label: 'Stream *',
                            value: _stream,
                            items: const [
                              'Science',
                              'Commerce',
                              'Arts',
                              'Computer Applications',
                              'Engineering',
                              'Other',
                            ],
                            onChanged: (v) => setState(() => _stream = v),
                          ),
                          _text(
                            'Favourite subjects',
                            _favSubjectsCtrl,
                            hint: 'e.g., Maths, Physics, Economics',
                          ),
                          _text(
                            'Technical skills',
                            _techSkillsCtrl,
                            hint: 'e.g., Python, SQL, Figma',
                          ),
                          _text(
                            'Soft skills',
                            _softSkillsCtrl,
                            hint: 'e.g., Communication, Leadership',
                          ),
                          _text(
                            'Interests',
                            _interestsCtrl,
                            hint: 'e.g., Design, Coding, Finance',
                          ),
                          _text(
                            'Target roles (optional)',
                            _targetRolesCtrl,
                            hint: 'e.g., Data Analyst, UI/UX Designer',
                          ),
                          _text(
                            'Preferred industry',
                            _industryCtrl,
                            hint: 'e.g., FinTech, Healthcare',
                          ),
                          _text(
                            'Preferred location',
                            _locationCtrl,
                            hint: 'e.g., Bengaluru, Remote',
                          ),
                          _dropdown(
                            label: 'Work mode',
                            value: _workMode,
                            items: const [
                              'On-site',
                              'Remote',
                              'Hybrid',
                              'No Preference',
                            ],
                            onChanged: (v) => setState(() => _workMode = v),
                          ),
                          _text(
                            'Salary expectation (annual)',
                            _salaryCtrl,
                            hint: 'e.g., ₹6–8 LPA',
                          ),
                          _text(
                            'Constraints',
                            _constraintsCtrl,
                            hint: 'e.g., Budget, time, relocation',
                          ),
                          _text(
                            'Portfolio/GitHub',
                            _portfolioCtrl,
                            hint: 'URL (optional)',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _submit,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.lightbulb_outline),
                          label: const Text('Submit'),
                        ),
                      ),
                      if (_guidance != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SelectableText(
                              _guidance!,
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _text(String label, TextEditingController ctrl, {String? hint}) {
    return SizedBox(
      width: 480,
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 480,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (label.contains('*') && (v == null || v.isEmpty)) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }
}
