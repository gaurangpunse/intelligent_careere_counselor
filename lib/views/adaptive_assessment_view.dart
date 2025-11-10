import 'package:flutter/material.dart';
import '../models/adaptive_question.dart';
import '../services/adaptive_assessment_service.dart';
import '../services/career_recommendation_engine.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import 'customized_career_guidance_results_page.dart';

class AdaptiveAssessmentView extends StatefulWidget {
  const AdaptiveAssessmentView({super.key});

  @override
  State<AdaptiveAssessmentView> createState() => _AdaptiveAssessmentViewState();
}

class _AdaptiveAssessmentViewState extends State<AdaptiveAssessmentView>
    with TickerProviderStateMixin {
  AssessmentSession? _session;
  AdaptiveQuestion? _currentQuestion;
  bool _isLoading = false;
  bool _isComplete = false;
  bool _isSavingResults = false;
  dynamic _currentAnswer;
  final Map<String, dynamic> _skillRatings = {};

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAssessment();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _startAssessment() async {
    setState(() => _isLoading = true);

    try {
      _session = await AdaptiveAssessmentService.instance.startNewSession();
      _loadCurrentQuestion();
    } catch (e) {
      _showError('Failed to start assessment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadCurrentQuestion() {
    if (_session == null) return;

    final service = AdaptiveAssessmentService.instance;
    _currentQuestion = service.getQuestionById(_session!.currentQuestionId);
    _currentAnswer = null;

    // Initialize rating questions with default values
    if (_currentQuestion?.type == QuestionType.rating) {
      final minRating = _currentQuestion!.minRating ?? 1.0;
      final defaultRatings = <String, dynamic>{};
      for (final option in _currentQuestion!.options) {
        defaultRatings[option.value] = minRating;
      }
      _currentAnswer = defaultRatings;
    }

    if (_currentQuestion != null) {
      _slideController.forward();
      _fadeController.forward();
    } else {
      _completeAssessment();
    }
  }

  Future<void> _answerQuestion() async {
    if (_currentQuestion == null || _currentAnswer == null || _session == null)
      return;

    setState(() => _isLoading = true);

    try {
      // Handle skill rating questions specially
      if (_currentQuestion!.type == QuestionType.rating) {
        _skillRatings.addAll(_currentAnswer as Map<String, dynamic>);
        _currentAnswer = _skillRatings;
      }

      _session = await AdaptiveAssessmentService.instance.addResponse(
        _session!,
        _currentQuestion!.id,
        _currentAnswer,
      );

      if (_session?.currentQuestionId == 'completed') {
        _completeAssessment();
      } else {
        await _slideController.reverse();
        await _fadeController.reverse();
        _loadCurrentQuestion();
      }
    } catch (e) {
      _showError('Failed to save answer: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeAssessment() async {
    if (_session == null) return;

    setState(() {
      _isComplete = true;
      _isLoading = true;
    });

    try {
      // Generate customized recommendations using the new engine
      final recommendationEngine = CareerRecommendationEngine.instance;
      final recommendations = recommendationEngine
          .generateCustomizedRecommendations(_session!);

      // Auto-save to Supabase
      final userId = AuthService.instance.userId ?? 'anonymous';
      final sessionData = {
        'session_id': _session!.id,
        'responses': _session!.responses.map((r) => r.toJson()).toList(),
        'progress_percentage': _session!.progressPercentage,
        'started_at': _session!.startedAt.toIso8601String(),
        'completed_at': DateTime.now().toIso8601String(),
        'context': _session!.context,
      };

      // Auto-save to Supabase
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSavingResults = true;
        });
      }

      try {
        await DataService.instance.saveAssessmentSession(
          userId: userId,
          sessionData: sessionData,
          recommendations: recommendations,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Assessment results saved successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (saveError) {
        // If save fails, show warning but continue to results
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Results generated but not saved: $saveError'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      // Navigate to customized results page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CustomizedCareerGuidanceResultsPage(
              session: _session!,
              recommendations: recommendations,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to generate recommendations: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSavingResults = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Assessment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          if (_session != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${_session!.responses.length + 1} of ~${_session!.responses.length + 5}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: _session?.progressPercentage != null
                ? _session!.progressPercentage / 100
                : 0.0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),

          Expanded(
            child: _isComplete
                ? _buildCompletionView()
                : _isLoading || _session == null
                ? _buildLoadingView()
                : _currentQuestion != null
                ? _buildQuestionView()
                : _buildErrorView(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    String loadingMessage = 'Processing your response...';
    if (_isComplete && _isSavingResults) {
      loadingMessage = 'Saving your results...';
    } else if (_isComplete) {
      loadingMessage = 'Generating your personalized recommendations...';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(loadingMessage, style: const TextStyle(fontSize: 16)),
          if (_isComplete) ...[
            const SizedBox(height: 8),
            const Text(
              'This may take a few moments',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Assessment Complete!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Generating your personalized career guidance...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Please try again'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startAssessment,
            child: const Text('Restart Assessment'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Question text
              Text(
                _currentQuestion!.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),

              if (_currentQuestion!.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  _currentQuestion!.subtitle!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],

              const SizedBox(height: 32),

              // Question content
              Expanded(child: _buildQuestionContent()),

              // Next button
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _currentAnswer != null && !_isLoading
                      ? _answerQuestion
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Next', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    switch (_currentQuestion!.type) {
      case QuestionType.singleChoice:
      case QuestionType.yesNo:
        return _buildSingleChoiceQuestion();
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceQuestion();
      case QuestionType.textInput:
        return _buildTextInputQuestion();
      case QuestionType.rating:
        return _buildRatingQuestion();
      case QuestionType.skillLevel:
        return _buildSkillLevelQuestion();
    }
  }

  Widget _buildSingleChoiceQuestion() {
    return ListView.builder(
      itemCount: _currentQuestion!.options.length,
      itemBuilder: (context, index) {
        final option = _currentQuestion!.options[index];
        final isSelected = _currentAnswer == option.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(option.text),
            leading: Radio<dynamic>(
              value: option.value,
              groupValue: _currentAnswer,
              onChanged: (value) {
                setState(() => _currentAnswer = value);
              },
            ),
            onTap: () {
              setState(() => _currentAnswer = option.value);
            },
            tileColor: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildMultipleChoiceQuestion() {
    final selectedOptions = _currentAnswer as List<dynamic>? ?? [];

    return ListView.builder(
      itemCount: _currentQuestion!.options.length,
      itemBuilder: (context, index) {
        final option = _currentQuestion!.options[index];
        final isSelected = selectedOptions.contains(option.value);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(option.text),
            leading: Checkbox(
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  final newSelection = List<dynamic>.from(selectedOptions);
                  if (checked == true) {
                    if (newSelection.length <
                        (_currentQuestion!.maxSelections ?? 10)) {
                      newSelection.add(option.value);
                    }
                  } else {
                    newSelection.remove(option.value);
                  }
                  _currentAnswer = newSelection;
                });
              },
            ),
            onTap: () {
              setState(() {
                final newSelection = List<dynamic>.from(selectedOptions);
                if (isSelected) {
                  newSelection.remove(option.value);
                } else if (newSelection.length <
                    (_currentQuestion!.maxSelections ?? 10)) {
                  newSelection.add(option.value);
                }
                _currentAnswer = newSelection;
              });
            },
            tileColor: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildTextInputQuestion() {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() => _currentAnswer = value);
          },
          decoration: const InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRatingQuestion() {
    final ratings = _currentAnswer as Map<String, dynamic>? ?? {};

    return ListView.builder(
      itemCount: _currentQuestion!.options.length,
      itemBuilder: (context, index) {
        final option = _currentQuestion!.options[index];
        final minRating = _currentQuestion!.minRating ?? 1.0;
        final currentRating = ratings[option.value] ?? minRating;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('1', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: currentRating,
                        min: minRating,
                        max: _currentQuestion!.maxRating ?? 5.0,
                        divisions: 4,
                        label: currentRating.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            final newRatings = Map<String, dynamic>.from(
                              ratings,
                            );
                            newRatings[option.value] = value;
                            _currentAnswer = newRatings;
                          });
                        },
                      ),
                    ),
                    const Text('5', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Text(
                  'Rating: ${currentRating.round()}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkillLevelQuestion() {
    return _buildSingleChoiceQuestion(); // Same as single choice for now
  }
}
