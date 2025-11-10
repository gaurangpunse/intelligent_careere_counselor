import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/career_guidance.dart';
import '../services/data_service.dart';

class CareerGuidanceResultsPage extends StatefulWidget {
  final CareerGuidance guidance;
  final bool isNewGuidance;

  const CareerGuidanceResultsPage({
    super.key,
    required this.guidance,
    this.isNewGuidance = true,
  });

  @override
  State<CareerGuidanceResultsPage> createState() =>
      _CareerGuidanceResultsPageState();
}

class _CareerGuidanceResultsPageState extends State<CareerGuidanceResultsPage> {
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isNewGuidance) {
      _isSaved = true;
    }
  }

  Future<void> _saveGuidance() async {
    if (_isSaved) return;

    setState(() => _isSaving = true);

    try {
      await DataService.instance.saveCareerGuidance(widget.guidance);
      setState(() {
        _isSaved = true;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Career guidance saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save guidance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareGuidance() {
    final text =
        '''
Career Guidance Results:

${widget.guidance.response}

Generated on: ${widget.guidance.createdAt.toString().split('.')[0]}
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Career guidance copied to clipboard!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _retakeAssessment() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
  }

  void _backToDashboard() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Guidance Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _shareGuidance,
            icon: const Icon(Icons.share),
            tooltip: 'Share Results',
          ),
          if (!_isSaved)
            IconButton(
              onPressed: _isSaving ? null : _saveGuidance,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              tooltip: 'Save Results',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your Personalized Career Guidance',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generated on ${_formatDate(widget.guidance.createdAt)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    if (_isSaved) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Saved',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Career Recommendations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: SelectableText(
                        widget.guidance.response,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _retakeAssessment,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake Assessment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _backToDashboard,
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Back to Dashboard'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Assessment Summary (collapsible)
            Card(
              child: ExpansionTile(
                title: const Text('Assessment Summary'),
                leading: const Icon(Icons.summarize),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildAssessmentSummary(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentSummary() {
    final assessment = widget.guidance.assessmentData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (assessment['education'] != null)
          _buildSummaryItem('Education', assessment['education']),
        if (assessment['stream'] != null)
          _buildSummaryItem('Stream', assessment['stream']),
        if (assessment['work_mode'] != null)
          _buildSummaryItem('Work Mode', assessment['work_mode']),
        _buildSummaryItem(
          'Favorite Subjects',
          assessment['favorite_subjects'] ?? '',
        ),
        _buildSummaryItem(
          'Technical Skills',
          assessment['technical_skills'] ?? '',
        ),
        _buildSummaryItem('Soft Skills', assessment['soft_skills'] ?? ''),
        _buildSummaryItem('Interests', assessment['interests'] ?? ''),
        _buildSummaryItem('Target Roles', assessment['target_roles'] ?? ''),
        _buildSummaryItem(
          'Preferred Industry',
          assessment['preferred_industry'] ?? '',
        ),
        _buildSummaryItem(
          'Preferred Location',
          assessment['preferred_location'] ?? '',
        ),
        _buildSummaryItem(
          'Expected Salary',
          assessment['expected_salary'] ?? '',
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
