import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qiot_admin/data/top_menu_data.dart';
import 'package:qiot_admin/screens/notifications_screen.dart';
import 'package:qiot_admin/screens/user_list_screen.dart';
import 'package:qiot_admin/services/api/authentication.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DashboardScreen extends StatefulWidget {
  final FluroRouter router;
  const DashboardScreen({super.key, required this.router});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final data = TopMenuData();
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        body: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Container
                Container(
                  width: screenSize.width * 0.16,
                  height: screenSize.height,
                  color: const Color(0xFF004283).withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/logo.svg',
                            width: screenSize.width * 0.1,
                          ),
                          const Divider(
                            indent: 16,
                            endIndent: 16,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                height: screenSize.height * 0.6,
                                child: ListView.builder(
                                  itemCount: data.menu.length,
                                  itemBuilder: (context, index) =>
                                      _buildMenu(data, index),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Divider(
                            indent: 16,
                            endIndent: 16,
                          ),
                          ListTile(
                            onTap: () async {
                              Map<String, dynamic> signOutResult =
                                  await Authentication.signOut();
                              bool signOutSuccess =
                                  signOutResult['success'] ?? false;
                              String? errorMessage = signOutResult['error'];
                              if (signOutSuccess) {
                                Navigator.popAndPushNamed(context, '/');
                              } else {
                                // Authentication failed
                                print('Authentication failed: $errorMessage');
                              }
                            },
                            leading: const Icon(Icons.logout),
                            title: const Text('Logout'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Middle Container
                SizedBox(
                  width: screenSize.width * 0.68,
                  height: screenSize.height,
                  child: Center(
                    child: FutureBuilder(
                      future: null,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return getCustomMenu();
                      },
                    ),
                  ),
                ), // Right Container
                // Right Container
                Container(
                  width: screenSize.width * 0.16,
                  height: screenSize.height,
                  color: const Color(0xFFFFFFFF),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenSize.width * 0.16,
                        height: screenSize.height * 0.4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004283).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Educational Plan',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF004283),
                              ),
                            ),
                            SizedBox(
                              width: screenSize.width * 0.1,
                              height: screenSize.height * 0.1,
                              child: SvgPicture.asset(
                                'assets/svg/personal_plan.svg',
                                width: 96,
                                height: 96,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004283),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Upload',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: screenSize.width * 0.16,
                        height: screenSize.height * 0.4,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        margin: const EdgeInsets.all(16.0),
                        child: SfPdfViewer.network(
                          'https://storage.googleapis.com/qiot-test.appspot.com/AsthmaActionPlanUrls/66689c0a20474d104de2f3d7/1718138934575_asthma_action_plan.pdf',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(TopMenuData data, int index) {
    final bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004283) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                data.menu[index].icon,
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF004283),
              ),
              const SizedBox(width: 8.0),
              Text(
                data.menu[index].title,
                style: TextStyle(
                  fontSize: isSelected ? 14.0 : 12.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF004283),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getCustomMenu() {
    print(_selectedIndex);
    switch (_selectedIndex) {
      case 0:
        return const UserListScreen();
      case 1:
        return const NotificationsScreen();
    }
    return const UserListScreen();
  }
}
