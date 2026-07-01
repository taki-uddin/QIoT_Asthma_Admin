import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/screens/add_adult_patient_screen.dart';
import 'package:qiot_admin/screens/add_child_patient_screen.dart';

class AddUsersScreen extends StatelessWidget {
  const AddUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Users',
            style: GoogleFonts.manrope(
              color: WebColors.primaryBlue,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Register a new adult patient or add a child linked to a guardian.',
            style: GoogleFonts.manrope(
              color: WebColors.primaryGreyText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _PatientOptionCard(
                    icon: Icons.person_outline,
                    title: 'Add New Patient',
                    subtitle:
                        'Register an adult patient only. They can log in with email and password.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAdultPatientScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _PatientOptionCard(
                    icon: Icons.child_care_outlined,
                    title: 'Add New Patient (child)',
                    subtitle:
                        'Register a child and link to an existing or new guardian account.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddChildPatientScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PatientOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WebColors.primaryWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: WebColors.primaryBlue.withOpacity(0.15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: WebColors.primaryBlue),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: WebColors.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: WebColors.primaryGreyText,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: WebColors.primaryBlue,
                  foregroundColor: WebColors.primaryWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
