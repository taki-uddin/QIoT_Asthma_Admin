import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qiot_admin/data/top_menu_data.dart';
import 'package:qiot_admin/services/api/authentication.dart';
import 'package:qiot_admin/widgets/admin_app_bar.dart';

/// Dashboard chrome: left nav + app bar. Used on user detail and dashboard routes.
class AdminShell extends StatelessWidget {
  final String pageTitle;
  final String? pageSubtitle;
  final int selectedMenuIndex;
  final int returnTab;
  final bool showBackButton;
  final Widget body;

  const AdminShell({
    super.key,
    required this.pageTitle,
    required this.body,
    this.pageSubtitle,
    this.selectedMenuIndex = 0,
    this.returnTab = 0,
    this.showBackButton = false,
  });

  void _navigateToTab(BuildContext context, int index) {
    Navigator.of(context).pushReplacementNamed(
      '/dashboard',
      arguments: {'initialTab': index},
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final menu = TopMenuData().menu;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: showBackButton
            ? AdminAppBar(
                title: pageTitle,
                subtitle: pageSubtitle,
                returnTab: returnTab,
              )
            : AppBar(
                backgroundColor: const Color(0xFF004283),
                foregroundColor: Colors.white,
                elevation: 1,
                automaticallyImplyLeading: false,
                title: Text(
                  pageTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: screenSize.width * 0.16,
              color: const Color(0xFF004283).withOpacity(0.1),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/logo.svg',
                          width: screenSize.width * 0.1,
                        ),
                        const Divider(indent: 16, endIndent: 16),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: menu.length,
                            itemBuilder: (context, index) =>
                                _AdminNavItem(
                              icon: menu[index].icon,
                              title: menu[index].title,
                              isSelected: !showBackButton &&
                                  selectedMenuIndex == index,
                              onTap: () => _navigateToTab(context, index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    onTap: () async {
                      final result = await Authentication.signOut();
                      if (result['success'] == true && context.mounted) {
                        Navigator.popAndPushNamed(context, '/');
                      }
                    },
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? const Color(0xFF004283) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF004283),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: isSelected ? 14 : 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF004283),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
