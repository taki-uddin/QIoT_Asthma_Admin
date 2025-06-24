import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdfx/pdfx.dart';
import 'package:qiot_admin/data/top_menu_data.dart';
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/screens/add_users_screen.dart';
import 'package:qiot_admin/screens/notifications_screen.dart';
import 'package:qiot_admin/screens/user_list_screen.dart';
import 'package:qiot_admin/services/api/authentication.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:qiot_admin/services/api/dashboard_users_data.dart';

class DashboardScreen extends StatefulWidget {
  final FluroRouter router;
  const DashboardScreen({super.key, required this.router});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final data = TopMenuData();
  html.File? _selectedFile;
  String pdfUrl = '';
  PdfControllerPinch? pdfPinchController;

  @override
  void initState() {
    super.initState();
    getpdfUrl();
  }

  Future<void> getpdfUrl() async {
    final Map<String, dynamic>? pdfUrlData =
        await DashboardUsersData().getEducationalPlan();
    if (pdfUrlData != null) {
      setState(() {
        pdfUrl = pdfUrlData['educationalPlans'];
      });
      // Load PDF document once url is fetched
      await loadPdfDocument();
      logger.d('pdfUrlData: $pdfUrl');
    } else {
      logger.d('Failed to get pdf url');
    }
  }

  Future<void> loadPdfDocument() async {
    // Fetch PDF bytes asynchronously
    final Uint8List bytes = await fetchPdfBytes(pdfUrl);
    // Initialize PdfControllerPinch with document
    pdfPinchController = PdfControllerPinch(
      document: PdfDocument.openData(bytes),
    );
    // Update UI
    setState(() {});
  }

  Future<Uint8List> fetchPdfBytes(String pdfUrl) async {
    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load PDF: ${response.statusCode}');
    }
  }

  Future<void> uploadEP() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDF files as per API requirement
    );

    if (result != null) {
      PlatformFile file = result.files.single;

      // Validate file size (limit to 10MB)
      if (file.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'File size too large. Please select a file smaller than 10MB.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 16),
              Text('Uploading Educational Plan...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      try {
        // Create html.File from bytes for web
        List<int> bytes = file.bytes!.toList();
        setState(() {
          _selectedFile = html.File(bytes, file.name);
        });

        final Map<String, dynamic>? uploadResult =
            await DashboardUsersData().uploadEducationalPlan(_selectedFile!);

        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (uploadResult != null && uploadResult['status'] == 200) {
          logger.d('Educational Plan uploaded successfully!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Educational Plan uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (uploadResult != null && uploadResult['error'] != null) {
          logger.d('Upload failed: ${uploadResult['error']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${uploadResult['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          logger.d('Failed to upload Educational Plan - Unknown error');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Failed to upload Educational Plan. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        logger.d('Error during upload: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      logger.d('No file selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    logger
        .d("Access Token: ${SessionStorageHelpers.getStorage('accessToken')}");

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
                      Expanded(
                        flex: 10,
                        child: Column(
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
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
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
                                  logger.d(
                                      'Authentication failed: $errorMessage');
                                }
                              },
                              leading: const Icon(Icons.logout),
                              title: const Text('Logout'),
                            ),
                          ],
                        ),
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
                              onPressed: () {
                                uploadEP();
                              },
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
                        child: pdfPinchController != null
                            ? PdfViewPinch(
                                controller: pdfPinchController!,
                              )
                            : const SizedBox(),
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
    logger.d(_selectedIndex);
    switch (_selectedIndex) {
      case 0:
        return const UserListScreen();
      case 1:
        return const NotificationsScreen();
      case 2:
        return const AddUsersScreen();
    }
    return const UserListScreen();
  }
}
