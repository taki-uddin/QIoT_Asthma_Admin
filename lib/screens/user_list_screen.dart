import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';
import 'dart:html' as html;

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> userData = [];
  List<dynamic> filteredUserData = [];
  List<bool> _rowEnabled = [];
  html.File? _selectedFile;
  int _hoverIndex = -1;
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getAllUsersData();
  }

  Future<void> uploadUserAAP(String userId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.single;

      // Read the file bytes asynchronously
      List<int> bytes = file.bytes!.toList();

      setState(() {
        _selectedFile = html.File(bytes, file.name); // For web
      });

      try {
        final Map<String, dynamic>? uploadUserAAP = await DashboardUsersData()
            .uploadUsersAsthmaActionPlan(_selectedFile!, userId);
        if (uploadUserAAP != null) {
          print('Your Asthma Action Plan has been uploaded!');
        } else {
          print('Failed to upload Asthma Action Plan');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No file selected');
    }
  }

  Future<void> _getAllUsersData() async {
    DashboardUsersData.getAllUsersData().then(
      (value) async {
        if (value != null) {
          setState(() {
            userData = List.from(
                value['payload'].reversed); // Reverse the order of userData
            filteredUserData =
                List.from(userData); // Initialize filteredUserData
            // Initialize the _rowEnabled list based on the status field
            _rowEnabled = userData.map<bool>((user) {
              // Assuming 'Enable' means enabled and others mean disabled
              return user['status'] == 'Enabled';
            }).toList();
          });
        } else {
          print('Failed to get user data');
        }
      },
    );
  }

  void _filterUserData(String query) {
    setState(() {
      _searchQuery = query;
      filteredUserData = userData.where((user) {
        // Check if the 'inhaler' field contains the query (case-insensitive)
        return user['inhaler']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: TextField(
                          onChanged: _filterUserData,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search',
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF004283).withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Table Header
              Container(
                width: screenSize.width,
                // height: screenSize.height * 0.16,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004283).withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Inhaler Serial Number
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Inhaler Serial Number",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF004283),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    // Peakflow Baseline
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Peakflow Baseline",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF004283),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    // Personal Plan
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Personal Plan",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF004283),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    // Edit
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Edit",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF004283),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    // Delete
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Delete",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF004283),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    // Enable/Disable
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Enable/Disable",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF004283),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUserData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/usersdetails/${userData[index]['_id']}',
                          arguments: {'id': '${userData[index]['_id']}'},
                        );
                      },
                      child: MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            _hoverIndex = index;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _hoverIndex = -1;
                          });
                        },
                        child: Container(
                          width: screenSize.width,
                          // height: screenSize.height * 0.16,
                          height: 80,
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _hoverIndex == index
                                ? const Color(0xFF004283).withOpacity(0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF004283).withOpacity(0.05),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Inhaler Serial Number
                              Expanded(
                                flex: 4,
                                child: Text(
                                  filteredUserData[index]['inhaler'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF004283),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              // Peakflow Baseline
                              Expanded(
                                flex: 2,
                                child: Container(
                                  width: screenSize.width * 0.1,
                                  // height: screenSize.height * 0.12,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF004283)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Peakflow Baseline',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        _hoverIndex == index
                                            ? ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF004283),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Reset',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                '${filteredUserData[index]['baseLineScore']}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Personal Plan
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    uploadUserAAP(
                                        filteredUserData[index]['_id']);
                                  },
                                  child: Container(
                                    width: screenSize.width * 0.1,
                                    // height: screenSize.height * 0.12,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF004283)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/svg/personal_plan.svg',
                                            width: 24,
                                            height: 24,
                                          ),
                                          const Text(
                                            'Personal Plan',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Edit
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: screenSize.width * 0.1,
                                  height: screenSize.height * 0.04,
                                  child: const Center(
                                    child: Text(
                                      'Edit',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF004283),
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Delete
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: screenSize.width * 0.1,
                                  height: screenSize.height * 0.04,
                                  child: const Center(
                                    child: Text(
                                      'Delete',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF004283),
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Enable/Disable
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  width: screenSize.width * 0.1,
                                  height: 8,
                                  child: Center(
                                    child: Transform.scale(
                                      scale: 1, // Adjust scale as needed
                                      child: Switch(
                                        value: _rowEnabled[
                                            index], // Use _rowEnabled to enable/disable rows
                                        onChanged: (newValue) {
                                          setState(() {
                                            _rowEnabled[index] = newValue;
                                          });
                                        },
                                        activeColor: const Color(
                                            0xFF004283), // Set active color
                                        inactiveThumbColor: Colors
                                            .grey, // Set inactive thumb color
                                        inactiveTrackColor: Colors.grey[
                                            300], // Set inactive track color
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
