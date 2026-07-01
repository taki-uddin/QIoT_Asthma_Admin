import 'package:flutter/material.dart';
import 'package:qiot_admin/constants/web_colors.dart';
import 'package:qiot_admin/services/auth_session.dart';
import 'package:google_fonts/google_fonts.dart';

/// Validates session before showing protected admin screens.
class AuthGuard extends StatefulWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _checking = true;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _validate();
  }

  Future<void> _validate() async {
    final valid = await AuthSession.ensureValidSession();
    if (!mounted) return;

    if (!valid) {
      await AuthSession.redirectToLogin();
      setState(() {
        _checking = false;
        _allowed = false;
      });
      return;
    }

    setState(() {
      _checking = false;
      _allowed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: WebColors.primaryBlue),
              const SizedBox(height: 16),
              Text(
                'Checking session…',
                style: GoogleFonts.manrope(color: WebColors.primaryGreyText),
              ),
            ],
          ),
        ),
      );
    }

    if (!_allowed) {
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}
