import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Admin-styled parent link + child health progress breakdown (not mobile child UI).
class ChildAccountAdminPanel extends StatelessWidget {
  final String childName;
  final String parentId;
  final String parentName;
  final Map<String, dynamic>? healthScorePayload;
  final bool isLoading;
  final int returnTab;
  final VoidCallback onOpenParent;

  const ChildAccountAdminPanel({
    super.key,
    required this.childName,
    required this.parentId,
    required this.parentName,
    required this.onOpenParent,
    this.healthScorePayload,
    this.isLoading = false,
    this.returnTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionCard(
          title: 'Child account',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                childName,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Linked to a parent account. Progress below is calculated for this child only.',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Parent account',
          child: InkWell(
            onTap: onOpenParent,
            child: Row(
              children: [
                const Icon(Icons.supervised_user_circle,
                    color: Color(0xFF004283)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parentName,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F80ED),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      Text(
                        'View parent profile',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF004283)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Progress breakdown',
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : healthScorePayload == null
                  ? Text(
                      'Could not load health score.',
                      style: GoogleFonts.manrope(color: Colors.grey[700]),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _scoreRow(
                          'Overall health score',
                          healthScorePayload!['healthScore'],
                          highlight: true,
                        ),
                        const Divider(height: 20),
                        _scoreRow(
                          'Asthma control (ACT)',
                          healthScorePayload!['breakdown']?['actScore'],
                        ),
                        _scoreRow(
                          'Fitness',
                          healthScorePayload!['breakdown']?['fitnessScore'],
                        ),
                        _scoreRow(
                          'Stress',
                          healthScorePayload!['breakdown']?['stressScore'],
                        ),
                        _scoreRow(
                          'Peak flow',
                          healthScorePayload!['breakdown']?['peakFlowScore'],
                        ),
                        if (healthScorePayload!['peakFlowBaseline'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'PEF baseline: ${healthScorePayload!['peakFlowBaseline']}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _dataPointsSummary(healthScorePayload!),
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  String _dataPointsSummary(Map<String, dynamic> payload) {
    final dp = payload['dataPoints'];
    if (dp is! Map) return '';
    final act = dp['totalActTests'] ?? 0;
    final fit = dp['totalFitnessEntries'] ?? 0;
    final stress = dp['totalStressEntries'] ?? 0;
    final pef = dp['totalPeakFlowEntries'] ?? 0;
    return 'Records: $act ACT · $fit fitness · $stress stress · $pef peak flow';
  }

  Widget _scoreRow(String label, dynamic value, {bool highlight = false}) {
    final text = value?.toString() ?? '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: highlight ? 14 : 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          Text(
            text == '—' ? text : '$text / 5',
            style: GoogleFonts.manrope(
              fontSize: highlight ? 18 : 14,
              fontWeight: FontWeight.w800,
              color: highlight
                  ? const Color(0xFF004283)
                  : const Color(0xFF27AE60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF004283).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF004283),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
