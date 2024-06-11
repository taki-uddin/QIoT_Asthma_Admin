import 'package:flutter/material.dart';
import 'package:qiot_admin/services/api/dashboard_users_data.dart';

class UserDetails extends StatefulWidget {
  final String userId; // Add a field to store the user ID
  const UserDetails({super.key, required this.userId});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  List<dynamic> userData = [];
  bool hasData = false;

  @override
  void initState() {
    super.initState();
    _getUserByIdData(widget.userId);
  }

  Future<void> _getUserByIdData(String userId) async {
    DashboardUsersData.getUserByIdData(userId).then(
      (value) async {
        if (value != null) {
          setState(() {
            userData = value['payload'];
            hasData = true;
          });
        } else {
          print('Failed to get user data');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: hasData == false // Check if the data is available
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Container
                    SizedBox(
                      width: screenSize.width * 0.16,
                      height: screenSize.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'User ID: ${userData[0]['_id']}', // Display the user ID
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            'User Name: ${userData[0]['firstName']} ${userData[0]['lastName']}', // Display the user ID
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right Container
                    SizedBox(
                      width: screenSize.width * 0.84,
                      height: screenSize.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'User ID: ${widget.userId}', // Display the user ID
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
