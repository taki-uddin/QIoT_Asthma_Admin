import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/models/medication/medication_models.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';
import 'package:qiot_admin/services/api/medication_api.dart';
import 'package:qiot_admin/utils/asthma_action_plan_upload.dart';
import 'package:qiot_admin/utils/medication_display_utils.dart';
import 'package:qiot_admin/widgets/medication_form.dart';

class EditAdultPatientScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> initialUser;

  const EditAdultPatientScreen({
    super.key,
    required this.userId,
    required this.initialUser,
  });

  @override
  State<EditAdultPatientScreen> createState() => _EditAdultPatientScreenState();
}

class _EditAdultPatientScreenState extends State<EditAdultPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationFormKey = GlobalKey<MedicationFormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _baselineController = TextEditingController();
  final _gpController = TextEditingController();
  final _deviceIdController = TextEditingController();

  MedicationCatalog? _catalog;
  List<Map<String, dynamic>> _initialMedications = [];
  String? _asthmaActionPlanUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPlan = false;

  @override
  void initState() {
    super.initState();
    _populateFromUser(widget.initialUser);
    _load();
  }

  void _populateFromUser(Map<String, dynamic> user) {
    _firstNameController.text = user['firstName']?.toString() ?? '';
    _lastNameController.text = user['lastName']?.toString() ?? '';
    _emailController.text = user['email']?.toString() ?? '';
    _baselineController.text = user['baseLineScore']?.toString() ?? '';
    _gpController.text = user['practionerContact']?.toString() ?? '';
    _deviceIdController.text = user['inhaler']?.toString() ?? '';
    _initialMedications =
        MedicationDisplayUtils.parseMedicationMaps(user['medications']);
    _asthmaActionPlanUrl = AsthmaActionPlanUpload.planUrl(user);
  }

  Future<void> _load() async {
    try {
      final catalog = await MedicationApi.getCatalog();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Could not load medication catalog', isError: true);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _baselineController.dispose();
    _gpController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? WebColors.errorRed : WebColors.okGreen,
      ),
    );
  }

  Future<void> _uploadPlan() async {
    setState(() => _isUploadingPlan = true);
    try {
      final url = await AsthmaActionPlanUpload.pickAndUpload(widget.userId);
      if (!mounted) return;
      if (url != null) {
        setState(() => _asthmaActionPlanUrl = url);
        _showMessage('Asthma action plan uploaded');
      }
    } on AsthmaActionPlanUploadException catch (e) {
      if (mounted) _showMessage(e.message, isError: true);
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to upload asthma action plan', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isUploadingPlan = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _catalog == null) return;

    final validationError = _medicationFormKey.currentState?.validate();
    if (validationError != null) {
      _showMessage(validationError, isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final profileBody = <String, dynamic>{
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'practionerContact': _gpController.text.trim(),
      };
      final baselineText = _baselineController.text.trim();
      if (baselineText.isNotEmpty) {
        profileBody['baseLineScore'] = int.tryParse(baselineText) ?? 0;
      }

      final profileResponse = await DashboardUsersData.updateUserDataById(
        widget.userId,
        profileBody,
      );
      if (profileResponse == null || profileResponse['status'] != 201) {
        _showMessage(
          profileResponse?['message']?.toString() ??
              'Failed to update patient details',
          isError: true,
        );
        return;
      }

      final medications = _medicationFormKey.currentState!.buildPayload();
      final medResponse = await MedicationApi.updateUserMedications(
        widget.userId,
        medications,
      );
      if (medResponse == null || medResponse['status'] != 201) {
        _showMessage(
          medResponse?['message']?.toString() ?? 'Failed to update medications',
          isError: true,
        );
        return;
      }

      final deviceId = _deviceIdController.text.trim();
      if (deviceId.isNotEmpty) {
        await DashboardUsersData.updateUserDataById(
          widget.userId,
          {'inhaler': deviceId},
        );
      }

      if (!mounted) return;
      _showMessage('Patient updated successfully');
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          'Edit patient',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _sectionHeading('Patient details'),
                                const SizedBox(height: 16),
                                _field(
                                  controller: _firstNameController,
                                  label: 'First name',
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                _field(
                                  controller: _lastNameController,
                                  label: 'Last name',
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                _field(
                                  controller: _emailController,
                                  label: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _field(
                                  controller: _baselineController,
                                  label: 'Peak flow baseline',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                _field(
                                  controller: _gpController,
                                  label: 'GP / practitioner contact',
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 32),
                                _sectionHeading('Medications'),
                                const SizedBox(height: 8),
                                if (_catalog != null)
                                  MedicationForm(
                                    key: _medicationFormKey,
                                    catalog: _catalog!,
                                    deviceIdController: _deviceIdController,
                                    initialMedications: _initialMedications,
                                  ),
                                const SizedBox(height: 32),
                                _sectionHeading('Personal asthma action plan'),
                                const SizedBox(height: 8),
                                _buildActionPlanSection(),
                                const SizedBox(height: 32),
                                FilledButton(
                                  onPressed: _isSaving ? null : _save,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: WebColors.primaryBlue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Save changes',
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isSaving)
                  const ColoredBox(
                    color: Color(0x33FFFFFF),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }

  Widget _sectionHeading(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: WebColors.primaryBlue,
      ),
    );
  }

  Widget _buildActionPlanSection() {
    final hasPlan = _asthmaActionPlanUrl != null && _asthmaActionPlanUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebColors.primaryGrey.withOpacity(0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WebColors.primaryBlue.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasPlan ? 'Plan on file' : 'No plan uploaded',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: hasPlan ? WebColors.okGreen : WebColors.primaryGreyText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accepted formats: JPG, PNG, PDF. Max 5MB.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: WebColors.primaryGreyText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _isUploadingPlan ? null : _uploadPlan,
                icon: _isUploadingPlan
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(hasPlan ? 'Replace plan' : 'Upload plan'),
              ),
              if (hasPlan)
                TextButton.icon(
                  onPressed: () =>
                      AsthmaActionPlanUpload.openPlan(_asthmaActionPlanUrl!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open current plan'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
