import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top app bar for admin detail routes (web). [returnTab] restores dashboard menu index on back.
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final int returnTab;
  final List<Widget>? actions;

  const AdminAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.returnTab = 0,
    this.actions,
  });

  static int returnTabFromContext(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['returnTab'] is int) {
      return args['returnTab'] as int;
    }
    return 0;
  }

  static void navigateBack(BuildContext context, {int returnTab = 0}) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacementNamed(
      '/dashboard',
      arguments: {'initialTab': returnTab},
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF004283),
      foregroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: () => navigateBack(context, returnTab: returnTab),
      ),
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle!,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
      actions: actions,
    );
  }
}
