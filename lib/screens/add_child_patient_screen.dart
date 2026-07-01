import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';

class AddChildPatientScreen extends StatefulWidget {
  const AddChildPatientScreen({super.key});

  @override
  State<AddChildPatientScreen> createState() => _AddChildPatientScreenState();
}

class _AddChildPatientScreenState extends State<AddChildPatientScreen> {
  int _step = 0;
  bool _isLoadingGuardians = true;
  bool _isSubmitting = false;
  bool _createNewGuardian = false;

  List<Map<String, dynamic>> _guardians = [];
  Map<String, dynamic>? _selectedGuardian;

  final _guardianFirstName = TextEditingController();
  final _guardianLastName = TextEditingController();
  final _guardianEmail = TextEditingController();

  final _childFirstName = TextEditingController();
  final _childLastName = TextEditingController();
  final _childBaseline = TextEditingController();
  final _childInhaler = TextEditingController();
  String? _ageRange;

  static const _ageRangeOptions = ['5-10', '11-17'];

  @override
  void initState() {
    super.initState();
    _loadGuardians();
  }

  @override
  void dispose() {
    _guardianFirstName.dispose();
    _guardianLastName.dispose();
    _guardianEmail.dispose();
    _childFirstName.dispose();
    _childLastName.dispose();
    _childBaseline.dispose();
    _childInhaler.dispose();
    super.dispose();
  }

  Future<void> _loadGuardians() async {
    final data = await DashboardUsersData.getAllUsersData();
    if (!mounted) return;
    setState(() {
      _guardians = DashboardUsersData.filterGuardianCandidates(
        data?['payload'] as List<dynamic>? ?? [],
      );
      _isLoadingGuardians = false;
      if (_guardians.isEmpty) {
        _createNewGuardian = true;
      }
    });
  }

  String _guardianLabel(Map<String, dynamic> g) {
    final name = '${g['firstName'] ?? ''} ${g['lastName'] ?? ''}'.trim();
    final email = g['email']?.toString() ?? '';
    return email.isNotEmpty ? '$name ($email)' : name;
  }

  bool _validateGuardianStep() {
    if (_createNewGuardian) {
      if (_guardianFirstName.text.trim().isEmpty ||
          _guardianLastName.text.trim().isEmpty ||
          _guardianEmail.text.trim().isEmpty) {
        _showError('Please complete all guardian fields.');
        return false;
      }
      if (!_guardianEmail.text.contains('@')) {
        _showError('Enter a valid guardian email.');
        return false;
      }
    } else {
      if (_selectedGuardian == null) {
        _showError('Please select a guardian.');
        return false;
      }
    }
    return true;
  }

  bool _validateChildStep() {
    if (_childFirstName.text.trim().isEmpty ||
        _childLastName.text.trim().isEmpty ||
        _ageRange == null) {
      _showError('Child first name, last name, and age range are required.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: WebColors.errorRed),
    );
  }

  Future<void> _submit() async {
    if (!_validateGuardianStep() || !_validateChildStep()) return;

    setState(() => _isSubmitting = true);
    try {
      String parentId;

      if (_createNewGuardian) {
        final guardianResponse = await DashboardUsersData.createAdultPatient({
          'firstName': _guardianFirstName.text.trim(),
          'lastName': _guardianLastName.text.trim(),
          'email': _guardianEmail.text.trim(),
        });
        if (guardianResponse['status'] != 201) {
          if (!mounted) return;
          _showError(
            guardianResponse['message']?.toString() ??
                'Failed to create guardian account',
          );
          return;
        }
        final guardianPayload =
            guardianResponse['payload'] as Map<String, dynamic>?;
        if (guardianPayload?['setupEmailSent'] != true) {
          if (!mounted) return;
          _showError(
            'Guardian account created, but setup email failed. They can use Forgot Password in the app.',
          );
        }
        parentId =
            guardianResponse['payload']['_id']?.toString() ?? '';
        if (parentId.isEmpty) {
          if (!mounted) return;
          _showError('Guardian created but ID missing in response.');
          return;
        }
      } else {
        parentId = _selectedGuardian!['_id']?.toString() ?? '';
      }

      final childData = <String, dynamic>{
        'firstName': _childFirstName.text.trim(),
        'lastName': _childLastName.text.trim(),
        'ageRange': _ageRange,
        'baseLineScore':
            int.tryParse(_childBaseline.text.trim()) ?? 0,
      };
      if (_childInhaler.text.trim().isNotEmpty) {
        childData['inhaler'] = _childInhaler.text.trim();
      }

      final childResponse = await DashboardUsersData.addChildToUser(
        parentId,
        childData,
      );

      if (!mounted) return;

      if (childResponse['status'] == 201) {
        final child = childResponse['child'] as Map<String, dynamic>?;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Child ${child?['firstName'] ?? _childFirstName.text} added and linked to guardian.',
            ),
            backgroundColor: WebColors.okGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        _showError(
          childResponse['message']?.toString() ?? 'Failed to add child',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: WebColors.primaryBlue,
        foregroundColor: WebColors.primaryWhite,
        title: Text(
          'Add New Patient (child)',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingGuardians
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stepper(
                            currentStep: _step,
                            onStepContinue: () {
                              if (_step == 0) {
                                if (!_validateGuardianStep()) return;
                                setState(() => _step = 1);
                              } else if (_step == 1) {
                                if (!_validateChildStep()) return;
                                setState(() => _step = 2);
                              } else {
                                _submit();
                              }
                            },
                            onStepCancel: () {
                              if (_step > 0) {
                                setState(() => _step -= 1);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            controlsBuilder: (context, details) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  children: [
                                    FilledButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : details.onStepContinue,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: WebColors.primaryBlue,
                                      ),
                                      child: _isSubmitting && _step == 2
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(_step == 2
                                              ? 'Create child patient'
                                              : 'Next'),
                                    ),
                                    const SizedBox(width: 12),
                                    TextButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : details.onStepCancel,
                                      child: Text(
                                          _step == 0 ? 'Cancel' : 'Back'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            steps: [
                              Step(
                                title: Text(
                                  'Guardian',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Every child must be linked to a guardian account.',
                                ),
                                isActive: _step >= 0,
                                state: _step > 0
                                    ? StepState.complete
                                    : StepState.indexed,
                                content: _buildGuardianStep(),
                              ),
                              Step(
                                title: Text(
                                  'Child',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                isActive: _step >= 1,
                                state: _step > 1
                                    ? StepState.complete
                                    : StepState.indexed,
                                content: _buildChildStep(),
                              ),
                              Step(
                                title: Text(
                                  'Review',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                isActive: _step >= 2,
                                content: _buildReviewStep(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildGuardianStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Existing guardian'),
              icon: Icon(Icons.person_search),
            ),
            ButtonSegment(
              value: true,
              label: Text('New guardian'),
              icon: Icon(Icons.person_add),
            ),
          ],
          selected: {_createNewGuardian},
          onSelectionChanged: (s) {
            setState(() => _createNewGuardian = s.first);
          },
        ),
        const SizedBox(height: 20),
        if (!_createNewGuardian) ...[
          if (_guardians.isEmpty)
            Text(
              'No existing guardians found. Create a new guardian account.',
              style: GoogleFonts.manrope(color: WebColors.errorRed),
            )
          else
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedGuardian,
              decoration: InputDecoration(
                labelText: 'Select guardian',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _guardians
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(_guardianLabel(g)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedGuardian = v),
            ),
        ] else ...[
          _textField(_guardianFirstName, 'Guardian first name'),
          const SizedBox(height: 12),
          _textField(_guardianLastName, 'Guardian last name'),
          const SizedBox(height: 12),
          _textField(
            _guardianEmail,
            'Guardian email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          Text(
            'A welcome email will be sent. The guardian sets their password via Forgot Password in the QIoT app.',
            style: GoogleFonts.manrope(
              color: WebColors.primaryGreyText,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChildStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _textField(_childFirstName, 'Child first name'),
        const SizedBox(height: 12),
        _textField(_childLastName, 'Child last name'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _ageRange,
          decoration: InputDecoration(
            labelText: 'Age range',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: _ageRangeOptions
              .map(
                (a) => DropdownMenuItem(
                  value: a,
                  child: Text(a == '5-10' ? '5–10 years' : '11–17 years'),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _ageRange = v),
        ),
        const SizedBox(height: 12),
        _textField(
          _childBaseline,
          'Peak flow baseline (optional)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _textField(
          _childInhaler,
          'Inhaler device ID (optional)',
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    final guardianName = _createNewGuardian
        ? '${_guardianFirstName.text.trim()} ${_guardianLastName.text.trim()}'
        : _guardianLabel(_selectedGuardian ?? {});
    final guardianDetail = _createNewGuardian
        ? _guardianEmail.text.trim()
        : _selectedGuardian?['email']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _reviewRow('Guardian', guardianName),
        _reviewRow('Guardian email', guardianDetail),
        if (_createNewGuardian)
          const _reviewRow('Guardian account', 'Will be created'),
        const Divider(height: 32),
        _reviewRow(
          'Child',
          '${_childFirstName.text.trim()} ${_childLastName.text.trim()}',
        ),
        _reviewRow('Age range', _ageRange ?? '—'),
        if (_childBaseline.text.trim().isNotEmpty)
          _reviewRow('Baseline', _childBaseline.text.trim()),
        if (_childInhaler.text.trim().isNotEmpty)
          _reviewRow('Inhaler ID', _childInhaler.text.trim()),
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: suffix,
      ),
    );
  }
}

class _reviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _reviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: WebColors.primaryGreyText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(color: WebColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}
