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
import 'dart:typed_data';

import 'package:qiot_admin/services/api/dashboard_users_data.dart';
import 'package:qiot_admin/main.dart';

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
  String? pdfLoadError;
  bool isLoadingPdf = false;
  String fileType = 'PDF'; // Track current file type

  @override
  void initState() {
    super.initState();
    getpdfUrl();
  }

  Future<void> getpdfUrl() async {
    setState(() {
      isLoadingPdf = true;
      pdfLoadError = null;
      pdfPinchController = null;
    });

    try {
      final Map<String, dynamic>? fileUrlData =
          await DashboardUsersData().getEducationalPlan();
      if (fileUrlData != null) {
        String fileUrl = fileUrlData['educationalPlans'];

        // Determine file type from URL
        String detectedFileType = _getFileTypeFromUrl(fileUrl);

        setState(() {
          pdfUrl = fileUrl;
          fileType = detectedFileType;
        });

        // Load document based on file type
        if (fileType == 'PDF') {
          await loadPdfDocument();
        }
        logger.d('File URL: $pdfUrl, Type: $fileType');
      } else {
        setState(() {
          pdfLoadError = 'Failed to get file URL from server';
          isLoadingPdf = false;
        });
        logger.d('Failed to get file url');
      }
    } catch (e) {
      setState(() {
        pdfLoadError = 'Error getting file URL: $e';
        isLoadingPdf = false;
      });
      logger.d('Error getting file URL: $e');
    }
  }

  Future<void> loadPdfDocument() async {
    try {
      if (pdfUrl.isEmpty) {
        logger.d('PDF URL is empty, cannot load document');
        setState(() {
          pdfLoadError = 'No PDF URL available';
          isLoadingPdf = false;
        });
        return;
      }

      logger.d('Loading PDF document from: $pdfUrl');

      // Fetch PDF bytes asynchronously
      final Uint8List bytes = await fetchPdfBytes(pdfUrl);

      // Initialize PdfControllerPinch with document
      pdfPinchController = PdfControllerPinch(
        document: PdfDocument.openData(bytes),
      );

      logger.d('PDF document loaded successfully');

      // Update UI
      if (mounted) {
        setState(() {
          pdfLoadError = null;
          isLoadingPdf = false;
        });
      }
    } catch (e) {
      logger.d('Error loading PDF document: $e');
      // Reset the controller on error
      pdfPinchController = null;
      if (mounted) {
        setState(() {
          pdfLoadError = 'Failed to load PDF: ${e.toString()}';
          isLoadingPdf = false;
        });
      }
    }
  }

  Future<Uint8List> fetchPdfBytes(String pdfUrl) async {
    try {
      logger.d('Fetching PDF bytes from: $pdfUrl');

      // Add headers for better compatibility with Cloudinary
      final response = await http.get(
        Uri.parse(pdfUrl),
        headers: {
          'Accept': 'application/pdf,*/*',
          'User-Agent': 'QIoT-Admin-Dashboard/1.0',
        },
      );

      logger.d('HTTP Response status: ${response.statusCode}');
      logger.d('HTTP Response headers: ${response.headers}');
      logger.d('HTTP Response content length: ${response.bodyBytes.length}');

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          throw Exception('PDF file is empty');
        }

        // Validate PDF signature
        final bytes = response.bodyBytes;
        if (bytes.length < 4) {
          throw Exception('File too small to be a valid PDF');
        }

        // Check PDF magic bytes (%PDF)
        final header = String.fromCharCodes(bytes.take(4));
        if (!header.startsWith('%PDF')) {
          logger.d('Invalid PDF header: $header');
          throw Exception('File is not a valid PDF (header: $header)');
        }

        return bytes;
      } else {
        throw Exception(
            'Failed to load PDF: HTTP ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      logger.d('Error fetching PDF bytes: $e');
      rethrow;
    }
  }

  String _getFileTypeFromUrl(String url) {
    // Extract file extension from URL
    String extension = url.split('.').last.toLowerCase().split('?').first;

    switch (extension) {
      case 'pdf':
        return 'PDF';
      case 'png':
        return 'PNG';
      case 'jpg':
      case 'jpeg':
        return 'JPEG';
      case 'doc':
        return 'DOC';
      case 'docx':
        return 'DOCX';
      default:
        return 'PDF'; // Default to PDF for backward compatibility
    }
  }

  String _validateFileFormat(Uint8List bytes, String extension) {
    if (bytes.length < 4) {
      throw Exception('File too small to be valid');
    }

    // Get first few bytes for magic number validation
    List<int> header = bytes.take(10).toList();
    String headerStr = String.fromCharCodes(bytes.take(4));

    switch (extension) {
      case 'pdf':
        if (!headerStr.startsWith('%PDF')) {
          throw Exception('Invalid PDF file (header: $headerStr)');
        }
        return 'PDF';

      case 'png':
        // PNG magic number: 89 50 4E 47 0D 0A 1A 0A
        if (!(header[0] == 0x89 &&
            header[1] == 0x50 &&
            header[2] == 0x4E &&
            header[3] == 0x47)) {
          throw Exception('Invalid PNG file');
        }
        return 'PNG';

      case 'jpg':
      case 'jpeg':
        // JPEG magic number: FF D8 FF
        if (!(header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF)) {
          throw Exception('Invalid JPEG file');
        }
        return 'JPEG';

      case 'doc':
        // DOC magic number: D0 CF 11 E0 A1 B1 1A E1 (OLE compound document)
        if (!(header[0] == 0xD0 &&
            header[1] == 0xCF &&
            header[2] == 0x11 &&
            header[3] == 0xE0)) {
          throw Exception('Invalid DOC file');
        }
        return 'DOC';

      case 'docx':
        // DOCX magic number: 50 4B (ZIP format)
        if (!(header[0] == 0x50 && header[1] == 0x4B)) {
          throw Exception('Invalid DOCX file');
        }
        return 'DOCX';

      default:
        throw Exception('Unsupported file format: $extension');
    }
  }

  void _showFullScreenPdf() {
    if (pdfUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _FullScreenFileDialog(fileUrl: pdfUrl, fileType: fileType);
      },
    );
  }

  Future<void> uploadEP() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'png',
        'jpg',
        'jpeg',
        'doc',
        'docx'
      ], // Support multiple file types
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
        // Validate file bytes exist
        if (file.bytes == null) {
          throw Exception('File bytes are null');
        }

        // Log file info for debugging
        logger.d('Original file size: ${file.size} bytes');
        logger.d('File name: ${file.name}');
        logger.d('File extension: ${file.extension}');

        // Create html.File from bytes for web
        Uint8List bytes = file.bytes!;

        // Validate file format based on extension and magic bytes
        String extension = file.extension?.toLowerCase() ?? '';
        String fileType = _validateFileFormat(bytes, extension);

        logger.d('File validation passed. Type: $fileType');
        logger.d('Bytes length: ${bytes.length}');

        setState(() {
          _selectedFile = html.File([bytes], file.name);
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
          // Refresh the PDF preview after successful upload
          await getpdfUrl();
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
                        height: screenSize.height * 0.5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004283).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF004283).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Header with title and action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004283),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (pdfUrl.isNotEmpty)
                                      IconButton(
                                        onPressed: () {
                                          _showFullScreenPdf();
                                        },
                                        icon: const Icon(
                                          Icons.fullscreen,
                                          color: Color(0xFF004283),
                                          size: 20,
                                        ),
                                        tooltip: 'View Full Screen',
                                      ),
                                    IconButton(
                                      onPressed: () async {
                                        await getpdfUrl();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Preview refreshed'),
                                            backgroundColor: Colors.blue,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Color(0xFF004283),
                                        size: 20,
                                      ),
                                      tooltip: 'Refresh Preview',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // PDF Preview or placeholder
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF004283)
                                        .withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: _buildPdfPreview(),
                              ),
                            ),
                          ],
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

  Widget _buildPdfPreview() {
    if (pdfLoadError != null) {
      // Show error state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading PDF',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                pdfLoadError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await getpdfUrl();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004283),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    } else if (isLoadingPdf) {
      // Show loading state
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF004283),
            ),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                color: Color(0xFF004283),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else if (pdfUrl.isNotEmpty) {
      // Show appropriate viewer based on file type
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildFileViewer(),
      );
    } else {
      // Show empty state
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 48,
              color: Color(0xFF004283),
            ),
            SizedBox(height: 16),
            Text(
              'No Educational Plan',
              style: TextStyle(
                color: Color(0xFF004283),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Upload a file to see preview\n(PDF, PNG, JPEG, DOC, DOCX)',
              style: TextStyle(
                color: Color(0xFF004283),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFileViewer() {
    switch (fileType) {
      case 'PDF':
        if (pdfPinchController != null) {
          return PdfViewPinch(controller: pdfPinchController!);
        } else {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF004283)),
          );
        }

      case 'PNG':
      case 'JPEG':
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.network(
            pdfUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF004283)),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Failed to load image',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              );
            },
          ),
        );

      case 'DOC':
      case 'DOCX':
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description,
                size: 64,
                color: Color(0xFF004283),
              ),
              const SizedBox(height: 16),
              Text(
                '$fileType Document',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004283),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Click download to view document',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF004283),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Open document in new tab
                  html.window.open(pdfUrl, '_blank');
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download/View'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004283),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );

      default:
        return const Center(
          child: Text(
            'Unsupported file type',
            style: TextStyle(color: Color(0xFF004283)),
          ),
        );
    }
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

class _FullScreenFileDialog extends StatefulWidget {
  final String fileUrl;
  final String fileType;

  const _FullScreenFileDialog({required this.fileUrl, required this.fileType});

  @override
  State<_FullScreenFileDialog> createState() => _FullScreenFileDialogState();
}

class _FullScreenFileDialogState extends State<_FullScreenFileDialog> {
  PdfControllerPinch? fullScreenController;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdfForFullScreen();
  }

  Future<void> _loadPdfForFullScreen() async {
    try {
      logger.d('Loading ${widget.fileType} for full screen: ${widget.fileUrl}');

      // Skip loading for non-PDF files
      if (widget.fileType != 'PDF') {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = null;
          });
        }
        return;
      }

      // Fetch PDF bytes
      final response = await http.get(
        Uri.parse(widget.fileUrl),
        headers: {
          'Accept': 'application/pdf,*/*',
          'User-Agent': 'QIoT-Admin-Dashboard/1.0',
        },
      );

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          throw Exception('PDF file is empty');
        }

        // Validate PDF signature
        final bytes = response.bodyBytes;
        if (bytes.length < 4) {
          throw Exception('File too small to be a valid PDF');
        }

        final header = String.fromCharCodes(bytes.take(4));
        if (!header.startsWith('%PDF')) {
          throw Exception('File is not a valid PDF');
        }

        // Create controller for full screen
        fullScreenController = PdfControllerPinch(
          document: PdfDocument.openData(bytes),
        );

        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = null;
          });
        }

        logger.d('Full screen PDF loaded successfully');
      } else {
        throw Exception('Failed to load PDF: HTTP ${response.statusCode}');
      }
    } catch (e) {
      logger.d('Error loading PDF for full screen: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    fullScreenController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color(0xFF004283),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Educational Plan - Full View (${widget.fileType})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // PDF Viewer
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: _buildFullScreenContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenContent() {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading PDF',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadPdfForFullScreen();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004283),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF004283),
            ),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                color: Color(0xFF004283),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else {
      // Show appropriate viewer based on file type
      switch (widget.fileType) {
        case 'PDF':
          if (fullScreenController != null) {
            return PdfViewPinch(controller: fullScreenController!);
          } else {
            return const Center(
              child: Text(
                'No PDF available',
                style: TextStyle(
                  color: Color(0xFF004283),
                  fontSize: 16,
                ),
              ),
            );
          }

        case 'PNG':
        case 'JPEG':
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              widget.fileUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF004283)),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Failed to load image',
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          );

        case 'DOC':
        case 'DOCX':
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.description,
                  size: 80,
                  color: Color(0xFF004283),
                ),
                const SizedBox(height: 24),
                Text(
                  '${widget.fileType} Document',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004283),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Click below to download and view the document',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF004283),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    html.window.open(widget.fileUrl, '_blank');
                  },
                  icon: const Icon(Icons.download, size: 24),
                  label: const Text('Download/View',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004283),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );

        default:
          return const Center(
            child: Text(
              'Unsupported file type',
              style: TextStyle(
                color: Color(0xFF004283),
                fontSize: 16,
              ),
            ),
          );
      }
    }
  }
}
