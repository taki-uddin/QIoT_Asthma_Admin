import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';

class AddAdultPatientScreen extends StatefulWidget {
  const AddAdultPatientScreen({super.key});

  @override
  State<AddAdultPatientScreen> createState() => _AddAdultPatientScreenState();
}

class _AddAdultPatientScreenState extends State<AddAdultPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _baselineController = TextEditingController();
  final _gpController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _baselineController.dispose();
    _gpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await DashboardUsersData.createAdultPatient({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        if (_baselineController.text.trim().isNotEmpty)
          'baseLineScore': int.tryParse(_baselineController.text.trim()) ?? 0,
        if (_gpController.text.trim().isNotEmpty)
          'practionerContact': _gpController.text.trim(),
      });

      if (!mounted) return;

      if (response['status'] == 201) {
        final payload = response['payload'] as Map<String, dynamic>?;
        final emailSent = payload?['setupEmailSent'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              emailSent
                  ? 'Patient ${payload?['firstName'] ?? ''} ${payload?['lastName'] ?? ''} created. Setup email sent to ${payload?['email'] ?? 'patient'}.'
                  : 'Patient created, but the setup email could not be sent. Ask them to use Forgot Password in the app.',
            ),
            backgroundColor:
                emailSent ? WebColors.okGreen : WebColors.errorRed,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message']?.toString() ?? 'Failed to create patient',
            ),
            backgroundColor: WebColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: WebColors.errorRed,
        ),
      );
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
          'Add New Patient',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
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
                      Text(
                        'Adult patient details',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: WebColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The patient will receive an email with instructions to set their password in the QIoT app (Forgot Password → verification code → choose password).',
                        style: GoogleFonts.manrope(
                          color: WebColors.primaryGreyText,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _field(
                        controller: _firstNameController,
                        label: 'First name',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: _lastNameController,
                        label: 'Last name',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: _baselineController,
                        label: 'Peak flow baseline (optional)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: _gpController,
                        label: 'GP / practitioner contact (optional)',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: WebColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Create patient',
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
